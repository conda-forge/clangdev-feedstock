About clang_packages
====================

Home: http://llvm.org/

Package license: Apache-2.0 WITH LLVM-exception

Feedstock license: BSD 3-Clause

Summary: Development headers and libraries for Clang



Current build status
====================


<table>
    
  <tr>
    <td>Azure</td>
    <td>
      <details>
        <summary>
          <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=153&branchName=master">
            <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/clangdev-feedstock?branchName=master">
          </a>
        </summary>
        <table>
          <thead><tr><th>Variant</th><th>Status</th></tr></thead>
          <tbody><tr>
              <td>linux_variantdefault</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=153&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/clangdev-feedstock?branchName=master&jobName=linux&configuration=linux_variantdefault" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>osx</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=153&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/clangdev-feedstock?branchName=master&jobName=osx&configuration=osx_" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>win</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=153&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/clangdev-feedstock?branchName=master&jobName=win&configuration=win_" alt="variant">
                </a>
              </td>
            </tr>
          </tbody>
        </table>
      </details>
    </td>
  </tr>
  <tr>
    <td>Linux_ppc64le</td>
    <td>
      <img src="https://img.shields.io/badge/ppc64le-disabled-lightgrey.svg" alt="ppc64le disabled">
    </td>
  </tr>
</table>

Current release info
====================

| Name | Downloads | Version | Platforms |
| --- | --- | --- | --- |
| [![Conda Recipe](https://img.shields.io/badge/recipe-clang-green.svg)](https://anaconda.org/conda-forge/clang) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/clang.svg)](https://anaconda.org/conda-forge/clang) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/clang.svg)](https://anaconda.org/conda-forge/clang) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/clang.svg)](https://anaconda.org/conda-forge/clang) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-clang--tools-green.svg)](https://anaconda.org/conda-forge/clang-tools) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/clang-tools.svg)](https://anaconda.org/conda-forge/clang-tools) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/clang-tools.svg)](https://anaconda.org/conda-forge/clang-tools) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/clang-tools.svg)](https://anaconda.org/conda-forge/clang-tools) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-clangdev-green.svg)](https://anaconda.org/conda-forge/clangdev) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/clangdev.svg)](https://anaconda.org/conda-forge/clangdev) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/clangdev.svg)](https://anaconda.org/conda-forge/clangdev) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/clangdev.svg)](https://anaconda.org/conda-forge/clangdev) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-clangxx-green.svg)](https://anaconda.org/conda-forge/clangxx) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/clangxx.svg)](https://anaconda.org/conda-forge/clangxx) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/clangxx.svg)](https://anaconda.org/conda-forge/clangxx) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/clangxx.svg)](https://anaconda.org/conda-forge/clangxx) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-libclang-green.svg)](https://anaconda.org/conda-forge/libclang) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/libclang.svg)](https://anaconda.org/conda-forge/libclang) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/libclang.svg)](https://anaconda.org/conda-forge/libclang) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/libclang.svg)](https://anaconda.org/conda-forge/libclang) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-python--clang-green.svg)](https://anaconda.org/conda-forge/python-clang) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/python-clang.svg)](https://anaconda.org/conda-forge/python-clang) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/python-clang.svg)](https://anaconda.org/conda-forge/python-clang) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/python-clang.svg)](https://anaconda.org/conda-forge/python-clang) |

Installing clang_packages
=========================

Installing `clang_packages` from the `conda-forge` channel can be achieved by adding `conda-forge` to your channels with:

```
conda config --add channels conda-forge
```

Once the `conda-forge` channel has been enabled, `clang, clang-tools, clangdev, clangxx, libclang, python-clang` can be installed with:

```
conda install clang clang-tools clangdev clangxx libclang python-clang
```

It is possible to list all of the versions of `clang` available on your platform with:

```
conda search clang --channel conda-forge
```


About conda-forge
=================

[![Powered by NumFOCUS](https://img.shields.io/badge/powered%20by-NumFOCUS-orange.svg?style=flat&colorA=E1523D&colorB=007D8A)](http://numfocus.org)

conda-forge is a community-led conda channel of installable packages.
In order to provide high-quality builds, the process has been automated into the
conda-forge GitHub organization. The conda-forge organization contains one repository
for each of the installable packages. Such a repository is known as a *feedstock*.

A feedstock is made up of a conda recipe (the instructions on what and how to build
the package) and the necessary configurations for automatic building using freely
available continuous integration services. Thanks to the awesome service provided by
[CircleCI](https://circleci.com/), [AppVeyor](https://www.appveyor.com/)
and [TravisCI](https://travis-ci.com/) it is possible to build and upload installable
packages to the [conda-forge](https://anaconda.org/conda-forge)
[Anaconda-Cloud](https://anaconda.org/) channel for Linux, Windows and OSX respectively.

To manage the continuous integration and simplify feedstock maintenance
[conda-smithy](https://github.com/conda-forge/conda-smithy) has been developed.
Using the ``conda-forge.yml`` within this repository, it is possible to re-render all of
this feedstock's supporting files (e.g. the CI configuration files) with ``conda smithy rerender``.

For more information please check the [conda-forge documentation](https://conda-forge.org/docs/).

Terminology
===========

**feedstock** - the conda recipe (raw material), supporting scripts and CI configuration.

**conda-smithy** - the tool which helps orchestrate the feedstock.
                   Its primary use is in the construction of the CI ``.yml`` files
                   and simplify the management of *many* feedstocks.

**conda-forge** - the place where the feedstock and smithy live and work to
                  produce the finished article (built conda distributions)


Updating clang_packages-feedstock
=================================

If you would like to improve the clang_packages recipe or build a new
package version, please fork this repository and submit a PR. Upon submission,
your changes will be run on the appropriate platforms to give the reviewer an
opportunity to confirm that the changes result in a successful build. Once
merged, the recipe will be re-built and uploaded automatically to the
`conda-forge` channel, whereupon the built conda packages will be available for
everybody to install and use from the `conda-forge` channel.
Note that all branches in the conda-forge/clang_packages-feedstock are
immediately built and any created packages are uploaded, so PRs should be based
on branches in forks and branches in the main repository should only be used to
build distinct package versions.

In order to produce a uniquely identifiable distribution:
 * If the version of a package **is not** being increased, please add or increase
   the [``build/number``](https://conda.io/docs/user-guide/tasks/build-packages/define-metadata.html#build-number-and-string).
 * If the version of a package **is** being increased, please remember to return
   the [``build/number``](https://conda.io/docs/user-guide/tasks/build-packages/define-metadata.html#build-number-and-string)
   back to 0.

Feedstock Maintainers
=====================

* [@SylvainCorlay](https://github.com/SylvainCorlay/)
* [@inducer](https://github.com/inducer/)
* [@isuruf](https://github.com/isuruf/)
* [@jakirkham](https://github.com/jakirkham/)
* [@timsnyder](https://github.com/timsnyder/)

