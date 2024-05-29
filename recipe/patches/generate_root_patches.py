"""
Script to generate the patch files needed by ROOT for clang. It is based on the
upstream LLVM tag and the ROOT tag of the current build. The latter is then used
to retrieve the tag of the ROOT LLVM fork which contains the needed patches.

Once the patches have been generated, the following can be used to add them to
the meta.yaml file. To be used within the patches/root directory.

print("\n".join(
    [f'      - patches/root/{name}  # [variant and variant.startswith("root_")]'
     for name in os.listdir()]))
"""
import glob
import os
import shlex
import shutil
import subprocess
from contextlib import contextmanager


@contextmanager
def change_directory(path: str):
    """Change to 'path' directory and restore it when done."""
    old_dir = os.getcwd()
    try:
        os.chdir(path)
        yield
    finally:
        os.chdir(old_dir)


LLVM_TAG = "llvmorg-16.0.6"
ROOT_TAG = "v6-32-00"


def retrieve_root_llvm_fork_tag() -> str:
    """
    Retrieve the correct tag for the
    llvm-project fork used by the ROOT build.
    """
    tag = f"https://raw.githubusercontent.com/root-project/root/{ROOT_TAG}/interpreter/llvm-project/llvm-project.tag"
    cmd = shlex.split(f"curl -s {tag}")
    p = subprocess.run(cmd, check=True, capture_output=True, text=True)
    return p.stdout


ROOT_LLVM_TAG = retrieve_root_llvm_fork_tag()


def main() -> None:
    """
    Generate the patches files for clang so it
    can be used by the ROOT version defined by
    the ROOT_TAG variable.
    """

    try:
        # Clone the fork and fetch the correct upstream tag
        subprocess.run(shlex.split(
            f"git clone --single-branch --branch {ROOT_LLVM_TAG} https://github.com/root-project/llvm-project.git"),
            check=True)

        # Generate the patch files between the two tags
        patch_files_dir = os.path.join(os.getcwd(), "root")
        with change_directory("llvm-project"):
            subprocess.run(shlex.split(
                "git remote add upstream https://github.com/llvm/llvm-project.git"), check=True)
            subprocess.run(shlex.split(
                f"git fetch --no-tags upstream refs/tags/{LLVM_TAG}:refs/tags/{LLVM_TAG}"), check=True)
            # Only create patch files for the commits related to clang
            subprocess.run(shlex.split(
                f"git format-patch --no-signature refs/tags/{LLVM_TAG} -- clang/"), check=True)

            # Move files to the patch directory
            patch_files = glob.glob("*.patch")
            for f in patch_files:
                os.rename(f, os.path.join(patch_files_dir, f))
    finally:
        shutil.rmtree("llvm-project")


if __name__ == "__main__":
    raise SystemExit(main())
