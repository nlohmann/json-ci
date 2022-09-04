#!/usr/bin/env python3

import itertools
import pathlib
import re
import sys
import yaml

from cerberus import Validator
from gen import create_jinja_env, jinja_filter, DockerImage

if __name__ == "__main__":
    project_dir = pathlib.Path(sys.path[0]) / "../../"
    src_dir = project_dir / "src/workflows/"
    workflows_dir = project_dir / ".github/workflows/"

    # setup Jinja
    env = create_jinja_env(
        src_dir, variable_start_string="{=", variable_end_string="=}"
    )

    # collect all images from Dockerfiles
    for filename in project_dir.glob("Dockerfile.*"):
        DockerImage.from_dockerfile(filename, with_source=False)

    # make filenames relative to project directory
    DockerImage.normalize_filenames(project_dir)

    # sort images topologically
    DockerImage.solve_dependencies()

    # build context
    context = {
        "images": DockerImage.registry.values(),
    }

    for filename in src_dir.glob("*.yml.j2"):
        # load and render template
        template = env.get_template(filename.name)
        source = template.render(context)

        with open(workflows_dir / filename.stem, "w") as f:
            f.write(source.rstrip())
            f.write("\n")
