#!/usr/bin/env python3

import pathlib
import re
import sys
import yaml

from jinja2 import Environment, FileSystemLoader

CONFIG_FILE = 'config.yml'
RUN = 'RUN '
INDENT = 4
IMAGE_PATTERN = re.compile(r'(?P<base>\w+(-\w+)*)(-(?P<version>\d+(\.\d+(\.\d+)?)?))?')
KEYWORD_PATTERN = re.compile(r'^(?P<keyword>[A-Z]+)\s+')

def docker_fuse_run(text):
    '''Merges consecutive RUN statements.'''

    lines = [line for line in map(str.strip, text.split('\n')) if line and not line.startswith('#')]
    out = []
    first_run = True

    for line in lines:
        match = KEYWORD_PATTERN.match(line)
        if match:
            if match.group('keyword') == 'RUN':
                if first_run:
                    first_run = False
                else:
                    out[-1] += ' && \\'
                    line = (' ' * len(RUN)) + line.removeprefix(RUN)
            else:
                first_run = True                
        else:
            line = (' ' * (len(RUN) + INDENT)) + line
        
        out.append(line)

    return '\n'.join(out)

def docker_multiline(text):
    '''Add line continuations.'''

    lines = [line for line in map(str.strip, text.split('\n')) if line and not line.startswith('#')]

    for line in lines:
        if not line.startswith(RUN):
            line = (' ' * (len(RUN) + INDENT)) + line

    return ' \\\n'.join(lines)

if __name__ == '__main__':
    project_dir = pathlib.Path(sys.path[0])
    src_dir = project_dir / 'src/docker/'
    template_dir = src_dir / 'templates/'

    # load config
    with open(project_dir / CONFIG_FILE, 'r') as f:
        config = yaml.safe_load(f)

    env = Environment(loader=FileSystemLoader(searchpath=[src_dir, template_dir]), autoescape=False, trim_blocks=True,
                                              lstrip_blocks=True, keep_trailing_newline=True)
    env.filters['docker.fuse_run'] = docker_fuse_run
    env.filters['docker.multiline'] = docker_multiline

    # for file in src_dir.glob('Dockerfile.*.j2'):
    #     image = file.stem.removeprefix('Dockerfile.')
    #     match = IMAGE_PATTERN.fullmatch(image)

    #     context = {
    #         'image': image,
    #         'image_base': match.group('base'),
    #         'image_version': match.group('version')
    #     }

    for key in config:
        entry = config[key]
        if not {'template', 'image', 'versions'} <= set(entry):
            raise ValueError(f'Invalid config entry: {key}')
        
        image_base = entry['image']
        for version in entry['versions']:
            image = f'{image_base}-{version}'
            context = {
                'image': image,
                'image_base': image_base,
                'image_version': version
            }

            template = env.get_template(entry['template'])
            dockerfile = docker_fuse_run(template.render(context))

            print(dockerfile)

            with open(project_dir / f'Dockerfile.{image}', 'w') as f:
                f.write(dockerfile)
