#!/usr/bin/env python3

import pathlib
import sys

from jinja2 import Environment, FileSystemLoader

if __name__ == '__main__':
    project_dir = pathlib.Path(sys.path[0])
    src_dir = project_dir / 'src/workflows/'
    template_dir = src_dir / 'templates/'
    workflows_dir = project_dir / '.github/workflows/'
    env = Environment('<%', '%>', '<%=', '%>', '<%#', '%>',
                      loader=FileSystemLoader(searchpath=[src_dir, template_dir]), autoescape=False, trim_blocks=True,
                                              lstrip_blocks=True, keep_trailing_newline=True)

    images = []
    for dockerfile in project_dir.glob('Dockerfile.*'):
        images.append(dockerfile.name.removeprefix('Dockerfile.'))

    context = {
        'images': images
    }

    for file in src_dir.glob('*.yml.j2'):
        template = env.get_template(str(file.relative_to(src_dir)))
        workflow = template.render(context)

        print(workflow)

        with open(workflows_dir / file.stem, 'w') as f:
            f.write(workflow)
