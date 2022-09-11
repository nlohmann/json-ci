import re
import sys

from functools import partial
from jinja2 import Environment, FileSystemLoader
from types import FunctionType, GeneratorType


class DockerImage:
    # Use double-hash for parser directives
    COMMENT_REGEX = re.compile(rf"^\s*#($|[^#].*)")

    _IMAGE_CLASS = r"[\w\-\.:]"
    FROM_REGEX = re.compile(
        rf"^\s*"
        rf"FROM\s+(?P<from>{_IMAGE_CLASS}+)\s+"
        rf"AS\s+(?P<as>json-ci-{_IMAGE_CLASS}+)"
    )

    registry = {}
    roots = []

    @staticmethod
    def from_dockerfile(dockerfile, source=None, with_source=True, register=True):
        if dockerfile and not source:
            with open(dockerfile, "r") as f:
                source = f.read()

        from_lines = 0
        lines = source.split("\n")
        images = []
        for line in lines:
            if match := DockerImage.FROM_REGEX.match(line):
                from_lines += 1
                name = match.group("as")
                parent = match.group("from")
                images.append(
                    DockerImage(
                        match.group("as"),
                        match.group("from"),
                        dockerfile,
                        source if with_source else None,
                    )
                )

        if with_source and from_lines != 1:
            raise RuntimeError(
                f"Expected exactly one FROM instruction, found {from_lines}."
            )

        if register:
            for image in images:
                DockerImage.register(image)

        return images

    @staticmethod
    def register(image):
        DockerImage.registry[image.name] = image

    @staticmethod
    def get(name):
        return DockerImage.registry.get(name, None)

    @staticmethod
    def solve_dependencies():
        # resolve parent names to objects
        for image in DockerImage.registry.values():
            image.parent = DockerImage.get(image.parent)

        # find images that are not themselves dependencies and are to be generated
        parents = set(
            image.parent.name for image in DockerImage.registry.values() if image.parent
        )
        roots = [
            image
            for image in DockerImage.registry.values()
            if image.generate and not image.name in parents
        ]

        # build dependency graphs via depth-first search
        for root in roots:
            graph = []
            visited = set()

            def visit(image):
                if image.name not in visited:
                    visited.add(image.name)
                    if image.parent and isinstance(image.parent, str):
                        image.parent = DockerImage.get(image.parent)
                if image.parent:
                    visit(image.parent)
                graph.append(image)

            # start depth-first search
            visit(root)
            root.is_root = True
            root.dependencies = list(reversed(graph[:-1]))

        DockerImage.roots = roots

    @staticmethod
    def normalize_filenames(root_dir):
        for image in DockerImage.registry.values():
            image.dockerfile = image.dockerfile.relative_to(root_dir)

    def __init__(self, name, parent, dockerfile, source=None):
        self.name = name
        self.real_parent = parent
        self.parent = parent
        self.dockerfile = dockerfile
        self.source = source
        self.generate = True
        self.publish = True
        self.is_root = False
        self.dependencies = []

    def __repr__(self):
        parent = (
            self.parent.name if isinstance(self.parent, DockerImage) else self.parent
        )
        return f"DockerImage({self.name}, parent={parent})"


class jinja_filter:
    filters = set()

    def __init__(self, fn):
        self.fn = fn
        self.name = fn.__name__.removeprefix("_").removeprefix("filter_")
        jinja_filter.filters.add(self)

    def __call__(self, input, *args, **kwargs):
        if isinstance(input, str):
            return self.fn(input, *args, **kwargs)
        elif isinstance(input, GeneratorType):
            return (self.fn(x, *args, **kwargs) for x in input)
        return [self.fn(x, *args, **kwargs) for x in input]


def create_jinja_env(searchpath, **kwargs):
    # setup Jinja
    env = Environment(
        loader=FileSystemLoader(searchpath=searchpath),
        extensions=["jinja2.ext.debug", "jinja2.ext.do"],
        autoescape=False,
        trim_blocks=True,
        lstrip_blocks=True,
        keep_trailing_newline=True,
        **kwargs,
    )

    # add filters
    for f in jinja_filter.filters:
        env.filters[f.name] = f

    # add globals
    env.globals["set"] = set
    env.globals["tuple"] = tuple

    return env


# custom Jinja filters
@jinja_filter
def _filter_append(input, suffix):
    return f"{input}{suffix}"


@jinja_filter
def _filter_prepend(input, prefix):
    return f"{prefix}{input}"


@jinja_filter
def _filter_format_as(input, fmt):
    return fmt.format(input)


@jinja_filter
def _filter_quote(input, q='"'):
    return f"{q}{input}{q}"


_SLUG_CHARS = "/-. "
_SLUG_TRANS = str.maketrans(_SLUG_CHARS, "_" * len(_SLUG_CHARS))


@jinja_filter
def _filter_slugify(input):
    return input.translate(_SLUG_TRANS)


@jinja_filter
def _filter_write_to_file(text, filename, lstrip=False, rstrip=False, append=True):
    match (lstrip, rstrip):
        case [True, False]:
            strip_fn = str.lstrip
        case [False, True]:
            strip_fn = str.rstrip
        case [True, True]:
            strip_fn = str.strip
        case _:
            strip_fn = lambda x: x

    res = [] if append else [f'RUN printf "" >"{filename}"']
    res += [
        f'RUN printf "{line}\\n" >>"{filename}"'
        for line in map(strip_fn, text.split("\n"))
    ]
    return "\n".join(res)
