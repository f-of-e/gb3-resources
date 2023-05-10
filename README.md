# gb3
**Note that commands in this README.md are run either on your local host terminal, or on a Docker container terminal. We highlight where to run a command immediately prior to the command itself. Make sure that you take care to note this.**

For example, consider the command below. This should be run in the host. **Run on host terminal**:
```bash
echo 'Hello Host'
```
This should be run in the container. **Run on container terminal**:
```bash
echo 'Hello Container'
```

## Prerequisites
### Install Docker
Follow the relevant instructions for your system on [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/).

### Install WSL and Prerequsites (if you are on windows)
If you are on Windows, you will need to install [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install) and a few other tools.
- Enable [Developer mode](https://learn.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development#activate-developer-mode)
- Ensure you have `git` installed, if not, [install it](https://github.com/git-guides/install-git#install-git-on-windows)
- Open a terminal with Administrator privilages
- Enable git symlinks by running:
	```bash
	git config --global core.symlinks true
	```
- Install `usbipd-win` with:
	```bash
	winget install usbipd
	```
- Install WSL with an Ubuntu distribution by following the [official instructions](https://learn.microsoft.com/en-us/windows/wsl/install). Ensure you are using WSL 2.
- Once WSL is installed, open a WSL ternimal (by typing `wsl` in the command prompt or PowerShell). In the WSL ternimal run the following commands:
	```bash
	sudo apt install linux-tools-5.4.0-77-generic hwdata
	sudo update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/5.4.0-77-generic/usbip 20
	```
- Restart your terminal

Note - You will only use WSL to load the built FPGA designs into the iCE40MDP with `iceprog`. For everything else, use the Docker image.

### Install Icestorm
We need the tool `iceprog` to program the ice40 FPGA. It comes as a part of the [icestorm](https://clifford.at/icestorm) toolkit. If you are on Windows, you should run these commands from insde a WSL terminal and follow the instructions for linux. You can intall the `icestorm` tools by following the instructions below:

- Clone the [icestorm repository](https://github.com/YosysHQ/icestorm/). **Run on host terminal**:
	```bash
	git clone https://github.com/YosysHQ/icestorm.git
	```
- change directories into the repository, and checkout the following commit. **Run on host terminal**:
	```
	cd <location of icestorm>
	git checkout d05659d83a3bb51ec5f7451d403fff9de1371c59
	```
- install the requirements for icestorm. How to do this will depend on your operating system:

    -  **macOS**:

	    - install [`homebrew`](https://brew.sh/). **Run on host terminal**:
			```bash
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
			```
		- use homebrew to install `libftdi`. **Run on host terminal**:
			```bash
			brew install libftdi
			```
		- install `gnu-sed`. **Run on host terminal**:
			```bash
			brew install gnu-sed
			```
		- temporarily use `gnu-sed` as the default. **Run on host terminal**:
			```bash
			export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
			```

	- **linux/WSL**:
		- update `apt-get`. **Run on host terminal**:
			```bash
			sudo apt-get update
			sudo apt-get upgrade -y
			```
		- install [`aptitude`](https://wiki.debian.org/Aptitude). **Run on host terminal**:
			```bash
			sudo apt-get install -y aptitude
			```
		- install `libftdi`. **Run on host terminal**:
			```bash
			sudo aptitude install -y libftdi-dev
			```
- Install `icestorm` by running the following from the root of the `icestorm` repository. **Run on host terminal**:
	```bash
	sudo make install
	```

- Remove the `icestorm` repository by running the following from the root of the `icestorm` repository. **Run on host terminal**:
	```bash
	cd ../
	rm -rf icestorm
	```

## Setting up GB3
To get started, fork and clone the following repository: [https://github.com/f-of-e/gb3-resources](https://github.com/f-of-e/gb3-resources).

This repository is organised as follows:
```
└── gb3-resources
    ├── Makefile
    ├── bubblesort		<-- implementation of bubble sort in C
    ├── gb3-Docker		<-- dockerfile and others for building gb3 Docker image
    ├── hardwareblink		<-- Verilog implementation of LED blinker
    ├── include			<-- header files for compiling C code
    ├── processor		<-- implementation of Sail RISC-V processor in Verilog
    ├── softwareblink		<-- implementation of LED blinker in C
    └── template		<-- template for writing and compiling C code for the Sail processor
```

Unless specified otherwise, we will assume that you are working from the root of this repository. Thus after cloning your fork, change directory into the root of the repository. **Run on host terminal**:
```bash
cd gb3
```

For this project, we provide a Docker image that has the required tools pre-installed. If you would like to install these tools locally, you can find instructions in Appendix X.

[Docker](https://www.docker.com/) is a platform that allows you to create, manage and run [*containers*](https://docs.docker.com/get-started/overview/#containers). A container is like a virtual-machine, in that it allows you to run a sandboxed operating system. It lets you package up your code and all its dependencies, which can include its runtime, system tools and libraries, and run it on any supported system, without having to worry about conflicts. Thus, you can, for example, run code built for Linux on MacOS.

A Docker container is different to a virtual-machine in that it uses the underlying operating system, rather than running a complete other operating system. This makes Docker containers much more lightweight, leading to faster spin-up times, and lower resource usage.

The package that a Docker container runs is called an [*image*](https://docs.docker.com/get-started/overview/#images). For GB3, we provide you with a pre-built image that contains the required tools all ready for you to use.

Images are built using a *dockerfile*. A dockerfile contains the steps needed to build the image. Although a pre-built image will be provided for you, we also provide you with the [dockerfile used to build it](docker/gb3-tools.Dockerfile). Run the following to build it. **Run on host terminal**:
```bash
cd docker
docker build --rm -f gb3-tools.Dockerfile -t <name of image>:latest .
```

### Pulling the Docker image
To use a Docker image, you must pull the Docker image. This image is stored in a container registry, much like package registries for software. **Run on host terminal**:
```bash
docker pull ghcr.io/f-of-e/gb3-tools:latest
```

You can inspect the image by using [docker inspect](https://docs.docker.com/engine/reference/commandline/inspect/). **Run on host terminal**:
```bash
docker inspect ghcr.io/f-of-e/gb3-tools:latest
```
This gives you some low-level information about the image. In particular, it shows the `Architecture` and the `Os` that the image was built for.

Once you have done that, you can interact with it by running a container that opens an interactive shell inside it. **Run on host terminal**:
```bash
docker run --rm -it ghcr.io/f-of-e/gb3-tools:latest /bin/bash
```
You can now interact with the operating system using the command line. Such a terminal is what we refer to as **a container terminal**.

Some IDEs, such a VSCode let you connect to a running container, allowing you to interact with the file system in the container through your IDE.

Exit the container by running `exit` inside the container. **Run on container terminal**:
```bash
exit
```
### Using Docker for GB3
The key files for this project located from the root of this repository. Among other things, you will be running and modifying code inside this folder.

Generally, any code written inside a Docker container are contained within it. For our purposes, it would be ideal if we can write code either outside, or in the container, and be able to access any changes from our host system. This can be achieved using [volumes](https://docs.docker.com/storage/volumes/).

Run the following command from the root of the repository. **Run on host terminal**:
```bash
docker run --rm -it -v $(pwd):/gb3-resources ghcr.io/f-of-e/gb3-tools:latest /bin/bash
```
**If you must run a command *in the container*, you must first run the command above.

This creates a mirror of the repository in the container, at location `/gb3-resources`. Thus, if you run `ls /` in the container, you should be able to see a folder `/gb3-resources`. Any changes made in the container or otherwise will be reflected in the other.

Note - If you are on Windows, you should run this command with the full path of the directory with the course tools instead of $(pwd). For example, if you cloned this repository to `D:\gb3-resources\`, you should run:

```bash
docker run --rm -it -v D:\gb3-resources\:/gb3-resources ghcr.io/f-of-e/gb3-tools:latest /bin/bash
```

You can exit the container by running `exit` inside the container. **Run on container terminal**:
```bash
exit
```

## Running the provided examples
You can connect the provided iCE40MDP to any USB-port of your computer.

**Note - If you are on windows**, you should run the above command from within the WSL ternimal and not the windows terminal.
You should attach the usb port to which the iCE40MDP is connected, to WSL.

- With the iCE40MDP _disconnected_, run the following command on your windows terminal (e.g., powershell):
	```bash
	usbipd wsl list
	```
- Connect the iCE40MDP to your computer and run the same command. You should see an extra device on the device list. Make a note of the `BUSID`.
- Attach you iCE40MDP to WSL by running:
	```bash
	usbipd wsl attach --busid <BUSID>
	```
where `<BUSID>` is the BUSID you noted down in the previous step. Note that this ID might change if you disconnect the device and connect it again.
- If this command is successful, you will be now be able to access your iCE40MDP from inside WSL

### Hardware blink
The folder `gb3-resources/hardwareblink` looks like the following:
```
└── gb3-resources
    ├── hardwareblink
    │   ├── Makefile
    │   ├── hardwareblink.pcf	<-- sets the led to the port D3 on the MDP
    │   └── hardwareblink.v	<-- the Verilog file with the hardware implementation
```

To build the binary that can be loaded to the FPGA, run the following. **Run on container terminal**:
```bash
cd /gb3
make hardwareblink
```
This will create a `design.bin` file inside `gb3-resources/build/`.

Finally, load the built binary to the MDP. **Run on host terminal**:
```bash
sudo iceprog -S build/design.bin
```

### Software blink
Software blink is an implementation of an LED blinker, but written in C. In particular, this code is run on an implementation of a RISC-V processor called the Sail core. The implementation of this CPU is in `gb3-resources/processor`.

`gb3-resources/softwareblink` looks like following:
```
└── gb3-resources
    ├── softwareblink
    │   ├── Makefile
    │   ├── README.md
    │   ├── init-sf.S
    │   ├── init.S
    │   ├── run.m
    │   ├── sail.ld
    │   ├── softwareblink.c	<-- Implementation of LED blinker in C
```
Compile `softwareblink/softwareblink.c`, and build the binary for the MDP. **Run on container terminal**:
```bash
cd /gb3-resources
make softwareblink
```
This will create a `design.bin` file inside `gb3-resources/build/`.

Finally, load the built binary to the MDP. **Run on host terminal**:
```bash
sudo iceprog -S build/design.bin
```

### Bubble sort
For a more complicated example that runs on the Sail core, we provide an implementation of bubble sort in `gb3-resources/bubblesort`, which looks like the following
```
└── gb3-resources
    ├── bubblesort
    │   ├── Makefile
    │   ├── README.md
    │   ├── init-sf.S
    │   ├── init.S
    │   ├── run.m
    │   ├── sail.ld
    │   ├── bubblesort.c	<-- Implementation of bubble sort in C
```
Compile `bubblesort/bubblesort.c`, and build the binary for the MDP. **Run on container terminal**:
```bash
cd /gb3-resources
make bubblesort
```
This will create a `design.bin` file inside `gb3-resources/build/`.

Finally, load the built binary to the MDP. **Run on host terminal**:
```bash
sudo iceprog -S build/design.bin
```
