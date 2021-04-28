import pandas as pd
import numpy as np
import os
from copy import copy

# change 
sample_list_file = "dfast_sample_list.xlsx"
job_file_name = "job_dfast_vrl.sh"


sheet_name = "Sheet1"

# output directory of metadata file
metadata_root_dir = "metadata"

result_root_dir = "results"  # output directory of dfast result file



ignore_keys = ["file_path"]

os.makedirs(metadata_root_dir, exist_ok=True)
os.makedirs(result_root_dir, exist_ok=True)




def get_defaul_metadata():
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
    metadata_file = os.path.join(metadata_root_dir, sample_id + ".metadata.txt")
    with open(metadata_file, "w") as f:
        for key, value in dict_metadata.items():
            if value:
                f.write(f"{key}\t{value}\n")
    return metadata_file

def make_dfast_cmd(sample_id, file_path, metadata_file):
    output_dir = os.path.join(result_root_dir, sample_id)
    cmd = f"singularity exec /lustre6/public/vrl/dfast_vrl:1.2-0.2.sif dfast_vrl -i {file_path} -m {metadata_file} -o {output_dir} --force"
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
#$ -o logs
#$ -e logs

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

df = pd.read_excel(sample_list_file, sheet_name=sheet_name, converters={"collection_date": str, "holdDate": str, "year": str, "ZIP": str})
df.fillna("", inplace=True)
df = df.astype(np.str)

commands = []
for index, S in df.iterrows():

    dict_metadata = get_defaul_metadata()
    for key, value in S.iteritems():
        if key in ignore_keys:
            continue
        value = value.strip()
        if value:
            dict_metadata[key] = value
    sample_id = S["isolate"].replace("/", "_")
    file_path = S["file_path"]
    print(f"#{index+1}: Generating metadata file for {sample_id}")
    metadata_file = write_metadata(sample_id, dict_metadata)
    cmd = make_dfast_cmd(sample_id, file_path, metadata_file)
    commands.append(cmd)
print("-----")
print(f"Generated job script to '{job_file_name}'")
write_job_script(job_file_name, commands)
