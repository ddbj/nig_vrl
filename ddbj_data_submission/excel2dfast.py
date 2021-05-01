import pandas as pd
import os
import sys
from copy import copy
from argparse import ArgumentParser


# PLEASE INSTALL pandas and openpyxl using conda/pip
# conda install pandas openpyxl

def parse_args():
    parser = ArgumentParser(description=f"excel2dfast.py: Prepare metadata files from Excel table and make a qsub job script.")
    parser.add_argument(
        "-i",
        "--input_excel_file",
        type=str,
        required=True,
        help="Input Excel file (e.g. dfast_sample_list.xlsx)",
        metavar="PATH"
    )
    parser.add_argument(
        "-o",
        "--output_job_file",
        type=str,
        default="job_dfast_vrl.sh",
        help="Input Excel file (default: job_dfast_vrl.sh)",
        metavar="PATH"
    )
    parser.add_argument(
        "-s",
        "--sheet_name",
        help="Excel sheet name to read from (e.g.: 'Sheet1'). If not specified, the 1st sheet will be read.",
        metavar="STR",
        default=0
    )
    parser.add_argument(
        "-m",
        "--metadata_dir",
        type=str,
        help="Directory where metadata files will be generated (default: metadata)",
        metavar="PATH",
        default="metadata"
    )
    parser.add_argument(
        "-r",
        "--result_dir",
        type=str,
        help="Root directory for job results (default: dfast_results)",
        metavar="PATH",
        default="dfast_results"
    )
    parser.add_argument(
        "-l",
        "--log_dir",
        type=str,
        help="Directory where log files of qsub jobs will be generated",
        metavar="PATH",
        default="logs"
    )

    if len(sys.argv)==1:
        parser.print_help()
        exit()
    args = parser.parse_args()

    return args

args = parse_args()

DFV_SINGULARITY_CONTAINER = os.environ.get("DFV_SINGULARITY_CONTAINER", "/lustre6/public/vrl/dfast_vrl:latest.sif")
DFV_SINGULARITY_OPTION = os.environ.get("DFV_SINGULARITY_OPTION", "")  # Option for 'singularity exex'  e.g. '-B /lustre6/privaate/vrl/'

sample_list_file = args.input_excel_file
job_file_name = args.output_job_file
sheet_name = args.sheet_name

metadata_root_dir = args.metadata_dir
result_root_dir = args.result_dir
log_dir = args.log_dir


if not os.path.exists(sample_list_file):
    print(f"Error. Excel file not found. [{sample_list_file}]")
    exit(1)

print(f"Creating metadata directory [{metadata_root_dir}]")
os.makedirs(metadata_root_dir, exist_ok=True)
print(f"Creating result root directory [{result_root_dir}]")
os.makedirs(result_root_dir, exist_ok=True)
print(f"Creating log directory [{log_dir}]")
os.makedirs(log_dir, exist_ok=True)


def get_default_metadata():
    dict_metadata_default = {
        "projectType": "vrl",
        "organism": "Severe acute respiratory syndrome coronavirus 2",
        "isolate": "",
        "isolation_source": "",
        "host": "Homo sapiens",
        "source_country": "Japan: Shizuoka",
        "bioproject": "",
        "biosample": "",
        "sra": "",
        "consrtm": "",
        "submitter": "Kamiyama,M.; Arita,M.",
        "contact": "Masayuki Kamiyama",
        "email": "kanki@pref.shizuoka.lg.jp",
        "url": "https://ddbj.nig.ac.jp",
        "phone": "81-54‐625‐9121",
        "phext": "",
        "fax": "",
        "institute": "Shizuoka Prefectural Institute of Public Health",
        "department": "Department of Microbiology",
        "country": "Japan",
        "state": "Shizuoka",
        "city": "Fujieda",
        "street": "232-1 Yainaba",
        "ZIP": "426-0083",
        "reference": "Whole-genome sequencing test of SARS-CoV-2 variants from Shizuoka samples supported by the cooperation between Shizuoka prefecture and NIG.",
        "author": "Kamiyama,M.; Arita,M.",
        "status": "Unpublished",
        "year": "2021",
        "journal": "",
        "holdDate": "",
        "comment": "Sequenced and annotated at NIG xxxxxxxx.",
        "assemblyMethod": "",
        "sequencingTechnology": "",
        "coverage": "",
    }
    return copy(dict_metadata_default)


# dict_mod_key = {
#     "ZIP": "zip",
#     "sequencingTechnology": "sequencing_technology",
#     "assemblyMethod": "assembly_method",
# }


def write_metadata(sample_id, dict_metadata):
    metadata_file = os.path.abspath(os.path.join(metadata_root_dir, sample_id + ".metadata.txt"))
    with open(metadata_file, "w") as f:
        for key, value in dict_metadata.items():
            if value:
                f.write(f"{key}\t{value}\n")
    return metadata_file

def make_dfast_cmd(sample_id, file_path, metadata_file):
    file_path = os.path.abspath(file_path)
    output_dir = os.path.abspath(os.path.join(result_root_dir, sample_id))
    options = "--force"
    if not os.path.exists(file_path):
        print(f"Aborted with an error: Query file not found [{file_path}]")
        exit(1)
    cmd = f"singularity exec {DFV_SINGULARITY_OPTION} {DFV_SINGULARITY_CONTAINER} dfast_vrl -i {file_path} -m {metadata_file} -o {output_dir} {options}"
    return cmd

def write_job_script(outfile_name, commands):
    job_length = len(commands)
    commands = "\n".join(['"' + cmd + '"' for cmd in commands])
    template = f"""\
#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l mem_req=16G,s_vmem=16G
#$ -t 1:{job_length}
#$ -o {log_dir}
#$ -e {log_dir}

COMMANDS=(
{commands}
)

CMD=${{COMMANDS[SGE_TASK_ID-1]}}
echo Running command: "$CMD"
eval $CMD

"""
    # print(template)
    with open(outfile_name, "w") as f:
        f.write(template)


def main():
    ignore_keys = ["file_path"]
    converters = {"collection_date": str, "holdDate": str, "year": str, "ZIP": str, "coverage": str}
    df = pd.read_excel(sample_list_file, sheet_name=sheet_name, converters=converters)
    df.fillna("", inplace=True)
    df = df.astype(str)

    commands = []
    print("-----")
    for index, S in df.iterrows():

        dict_metadata = get_default_metadata()
        for key, value in S.iteritems():
            if key in ignore_keys:
                continue
            value = value.strip()
            if value:
                if key == "coverage":
                    value = value + "x"
                dict_metadata[key] = value
        sample_id = S["isolate"].replace("/", "_")
        file_path = S["file_path"]
        if not file_path:
            break  # Break at empty line
        print(f"#{index+1}: Generating metadata file for {sample_id}")
        metadata_file = write_metadata(sample_id, dict_metadata)
        cmd = make_dfast_cmd(sample_id, file_path, metadata_file)
        commands.append(cmd)
    print("-----")
    print(f"Generated job script to '{job_file_name}'")
    print(f"Run 'qsub {job_file_name}' to launch the job.")
    write_job_script(job_file_name, commands)


if __name__ == '__main__':
    main()
