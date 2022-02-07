# MERMAID_work

Software to conduct the analysis and make the figures
in the paper **One year of sound recorded by a MERMAID float in the
Pacific: Hydroacoustic earthquake signals and infrasonic ambient
noise**, by Sirawich Pipatprathanporn and Frederik J Simons,
_Geophysical Journal International_ (2022)

### Cited as

Pipatprathanporn S., Simons F.J., 2021. One year of sound recorded by
a MERMAID float in the Pacific: Hydroacoustic earthquake signals and
infrasonic ambient noise, _Geophys. J. Int_.,
[doi.org/10.1093/gji/ggab296.](doi.org/10.1093/gji/ggab296)

Author: Sirawich Pipatprathanporn

Email:  sirawich@princeton.edu

## How to install the package

[0] Clone the repository

`git clone git@github.com:sirpipat/MERMAID_buffer.git`

[1] Install the following required dependent packages:

- [slepian_alpha](https://github.com/csdms-contrib/slepian_alpha)

- [slepian_oscar](https://github.com/csdms-contrib/slepian_oscar)

- [irisFetch](https://ds.iris.edu/ds/nodes/dmc/software/downloads/irisfetch.m/)

[2] The following environmental variable must be set in the shell:

export MERMAID=/where-you-clone-the-repoitory/

export ONEYEAR=/where-you-keep-the-buffer-files/

export SAC=/where-you-store-MERMAID-reports/

export IFILES=/where-you-keep-the-information-files/

export SFILES=/where-you-want-the-output-SAC-files-to-be/

export NCFILES=/where-you-keep-the-NetCDF-files/

export EPS=/where-you-want-plots-to-be-saved/

export SLEPIANS=/where-you-put-slepian\_alpha-and-slepian\_oscar/

export IRISFETCH=/where-you-keep-irisFetch/

[3] Add the following paths `startup.m`, so that MATLAB recognizes the installed packages

`
addpath(genpath(getenv('SLEPIANS')))
addpath(genpath(getenv('MERMAID')))
addpath(genpath(getenv('IRISFETCH')))
`