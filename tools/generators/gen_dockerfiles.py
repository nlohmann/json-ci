#!/usr/bin/env python3

import itertools
import pathlib
import re
import sys
import yaml

from cerberus import Validator
from gen import create_jinja_env, jinja_filter, DockerImage
from jinja2.utils import Namespace

CONFIG_SCHEMA = {
    "dockerfiles": {
        "type": "list",
        "schema": {
            "type": "dict",
            "schema": {
                "template": {"type": "string", "required": True},
                "filename": {"type": "string"},
                "generate": {
                    "type": "boolean",
                },
                "publish": {
                    "type": "boolean",
                },
                "with": {"type": "dict", "allow_unknown": True},
                "matrix": {
                    "type": "list",
                    "schema": {
                        "type": "dict",
                        "allow_unknown": True,
                        "schema": {
                            "with": {"type": "dict", "allow_unknown": True},
                        },
                    },
                },
            },
        },
    }
}
DOCKERFILE_TEMPLATE = "{{ template_stem }}"
KEYWORD_REGEX = re.compile(r"^(?P<keyword>[A-Z]+)\s+")
INDENT = 4


def fuse_statements(source):
    lines = [
        line
        for line in map(str.strip, source.split("\n"))
        if line and not DockerImage.COMMENT_REGEX.match(line)
    ]
    res = []
    last_keyword = None

    for line in lines:
        if match := KEYWORD_REGEX.match(line):
            keyword = match.group("keyword")
            # translate WORKDIR
            # TODO track workdir in a variable and prepend "cd <workdir>" to starting RUN instructions
            if keyword == "WORKDIR":
                line = "RUN cd" + line.removeprefix(keyword)
                keyword = "RUN"

            # fuse consecutive RUN statements
            if keyword == "RUN" and keyword == last_keyword:
                if res[-1].endswith("\\"):
                    res[-1] = res[-1].removesuffix("\\").rstrip()
                res[-1] += " && \\"
                line = (" " * len(keyword)) + line.removeprefix(keyword)

            # add newlines between instructions
            if keyword != last_keyword and len(res) > 0:
                # prepend an extra newline before different instructions
                res.append("")
                if keyword == "FROM":
                    # prepend an additional newline before FROM instructions
                    res.append("")
            last_keyword = keyword
        else:
            if not line.startswith("#") and not last_keyword:
                raise RuntimeError(
                    "Dockerfiles must start with a parser directive (##) or an instruction."
                )

            if last_keyword:
                if not res[-1].endswith("\\"):
                    res[-1] += " \\"
                line = (" " * (len(last_keyword) + 1 + INDENT)) + line
            elif line.startswith("#"):
                line = "#" + line.lstrip("#")

        res.append(line)

    return "\n".join(res) + "\n"


if __name__ == "__main__":
    project_dir = pathlib.Path(sys.path[0]) / "../../"
    src_dir = project_dir / "src/docker/"

    # load and validate config.yml
    with open(project_dir / "config.yml", "r") as f:
        config = yaml.safe_load(f)

        v = Validator(CONFIG_SCHEMA)
        if not v.validate(config):
            # TODO pretty print errors
            print(v.errors)
            sys.exit(1)

        config = config["dockerfiles"]

    # setup Jinja
    env = create_jinja_env(src_dir)

    for entry in config:
        template_path = pathlib.Path(entry["template"])
        default_context = {"template_stem": template_path.stem}
        template = env.get_template(template_path.name)

        # get template for Dockerfile filename
        file_template = env.from_string(entry.get("filename", DOCKERFILE_TEMPLATE))

        # update default_context with entry context
        default_context.update(entry.get("with", {}))

        for matrix in entry["matrix"]:
            matrix_context = default_context.copy()
            matrix_context.update(matrix.get("with", {}))
            # get the keys and values from the matrix entry for the cartesian product
            keys = [key for key in matrix if not key in ("with",)]
            values = [matrix[key] for key in keys]
            for product in itertools.product(*values):
                context = matrix_context.copy()
                context.update(dict(zip(keys, product)))

                # namespace object for sharing state in template code
                context["_state"] = Namespace()

                # render template with default_context + matrix_context + {keys:product} and fuse statements
                source = fuse_statements(template.render(context))

                # store image in DockerImage.registry
                dockerfile = file_template.render(context)
                image = DockerImage.from_dockerfile(dockerfile, source)[0]

                image.generate = entry.get("generate", True)
                image.publish = entry.get("publish", True)

    DockerImage.solve_dependencies()

    # build the list of images for each Dockerfile
    dockerfiles = {}
    for image in DockerImage.roots:
        if not image.generate:
            continue

        if not image.dockerfile in dockerfiles:
            dockerfiles[image.dockerfile] = []
        dockerfiles[image.dockerfile] += [*reversed(image.dependencies), image]

    # write image sources to Dockerfiles
    for dockerfile, images in dockerfiles.items():
        # remove duplicates
        images = list(dict.fromkeys(images))

        with open(dockerfile, "w") as f:
            f.write("\n\n".join(image.source for image in images).rstrip())
            f.write("\n")
