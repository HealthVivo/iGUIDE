.. _quickstart:

.. contents::
   :depth: 2



Initializing a Run
------------------

Once the config and sampleInfo files have been configured, a run directory can 
be created using the command below where {ConfigFile} is the path to your configuration file::

  cd path/to/iGUIDE
  iguide setup {ConfigFile}

The directory should look like this (RunName is specified in the ConfigFile}::
  
  > tree analysis/{RunName}
  analysis/{RunName}/
  ├── config.yml -> {path to ConfigFile}
  ├── input_data
  ├── logs
  ├── output
  ├── processData
  └── reports

Components within the run directory:

* config.yml - This is a symbolic link to the config file for the run
* input_data - Directory where input fastq.gz files can be deposited
* logs - Directory containing log files from processing steps
* output - Directory containing output data from the analysis
* processData - Directory containing intermediate processing files
* reports - Directory containing output reports and figures

As a current convention, all processing is done within the analysis directory. 
The above command will create a file directory under the analysis directory for 
the run specified in by the config ('/iGUIDE/analysis/{RunName}'). At the end of 
this process, iGUIDE will give the user a note to deposit the input sequence 
files into the /analysis/{RunName}/input_data directory. Copy the fastq.gz files 
from the sequencing instrument into this directory if you do not have paths to
the files specified in the config file.

Currently, iGUIDE needs each of the sequencing files (R1, R2, I1, and I2) for 
processing since it is based on a dual barcoding scheme. If I1 and I2 are 
concatenated into the read names of R1 and R2, it is recommended the you run 
``bcl2fastq ... --create-fastq-for-index-reads`` on the machine output 
directory to generate the I1 and I2 files. 

As iGUIDE has its own demultiplexing, it is recommend to not use the Illumina 
machine demultiplexing through input of index sequences in the SampleSheet.csv. 
See SampleSheet example in XXX. If sequence files are demultiplexed, they can be 
concatenated together into one file for each type of read using 'zcat'.


List Samples for a Run
----------------------

As long as the config and sampleInfo files are present and in their respective 
locations, you can get a quick view of what samples are related to the project.
Using the 'list_samples' subcommand will produce an overview table on the 
console or write the table to a file (specified by the output option). 
Additionally, if a supplemental information file is associated with the run, the
data will be combined with the listed table.::

  > iguide list_samples configs/simulation.config.yml
  
  Specimen Info for : simulation.

   specimen   replicates       gRNA        nuclease
  ---------- ------------ --------------- ----------
     iGXA         1            TRAC         Cas9v1
     iGXB         1        TRAC;TRBC;B2M    Cas9v1
     iGXD         1             NA            NA


Processing a Run
----------------

Once the input_data directory has the required sequencing files, the run can be 
processed using the following command::

  cd path/to/iGUIDE/
  iguide run {ConfigFile}

Snakemake offers a great number of resources for managing the processing through 
the pipeline. I recommend familiarizing yourself with the utility 
(https://snakemake.readthedocs.io/en/stable/). Here are some helpful snakemake
options that can be passed to iGUIDE by appending to the iguide command after '--':

* [\-\-configfile X] associate a specific configuration for processing, essential for processing
* [\-\-cores X] multicored processing, specified cores to use by X
* [\-\-nolock] process multiple runs a the same time, from different sessions
* [\-\-notemp] keep all temporary files, otherwise removed
* [\-\-keep-going] will keep processing if one or more job error out
* [-w X, \-\-latency-wait X] wait X seconds for the output files to appear before erroring out


An Example Run
--------------

To perform a local test of running the iGUIDE informatic pipeline, run the below 
code after installing. This block first activates your conda environment, 
``iguide`` by default, and then creates a test directory within the analysis 
directory. The run information is stored in the run specific configuration file 
(config file). Using the ``-np`` flag with the snakemake call will perform a 
dry-run (won't actually process anything) and print the commands to the 
terminal, so you can see what snakemake is about to perform. Next, the test data 
is moved to the input directory underneath the new test run directory. Then the 
entirety of processing can start. Using the ``--dag`` flag and piping the output 
to ``dot -Tsvg`` will generate a vector graphic of the directed acyclic graph 
(dag) workflow that snakemake will follow given the data provided::


  # Create test analysis directory
  # (The simulation configuration file is used by default and does not need to be specified)
  iguide setup configs/simulation.config.yml -- -np
  iguide setup configs/simulation.config.yml

  # Generate test DAG graph
  iguide run configs/simulation.config.yml -- -np
  iguide run configs/simulation.config.yml -- --dag | dot -Tsvg > analysis/simulation/reports/simulation.dag.svg
  iguide run configs/simulation.config.yml -- --latency-wait 30
  cat analysis/simulation/output/unique_sites.simulation.csv


Uninstall
---------

To uninstall iGUIDE, the user will need to remove the environment and the 
directory.

To remove the environment and channels used with conda::

  cd path/to/iGUIDE
  bash etc/uninstall.sh

Or::

  cd path/to/iGUIDE
  bash etc/uninstall.sh {env_name}

If the user would rather remove the environment created for iGUIDE, it is 
recommended directly use conda. This will leave the channels within the conda 
config for use with other conda configurations::

  conda env remove -n iguide

Or::

  conda env remove -n {env_name}

To remove the iGUIDE directory and conda, the following two commands can be 
used::

  # Remove iGUIDE directory and software
  rm -r path/to/iGUIDE

  # Remove conda
  rm -r path/to/miniconda3
