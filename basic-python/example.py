# -- coding: utf-8 --

import click
import yaml
import json

@click.command()
@click.option('-n', '--accession_number', help='Accession number')
@click.option('-e', '--environment', default='local', help='Environment.')
@click.option('--input', type=click.File('r'), required=False)
@click.option('--dryrun', is_flag=True, help='Dry run, nothing is actually changed.')
def process(environment, dryrun, accession_number=None, input=None):
    """A simple script."""
    with open('config.yaml', 'r') as f:
        config = yaml.load(f)

    if not accession_number and not input:
        click.echo('Nothing to process. Pass an accession number or input file\n')
        exit()

    accession_numbers = []

    if accession_number:
        accession_numbers.append(accession_number)
    elif input:
        for accession_number in input:
            accession_numbers.append(accession_number.rstrip())

    count=0
    for accession_number in accession_numbers:
        count += 1
        click.echo('===========================================================\n')
        click.echo('{count} - Running for {accession_number} on {environment}\n'.format(
            count=count,
            accession_number=accession_number,
            environment=environment
        ))


        if dryrun:
            click.echo("\nDry run...\n")
        else:
            click.echo("\nActual run...\n")

if __name__ == '__main__':
    process()
