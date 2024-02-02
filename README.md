# Integrate Slicer in a TEE with Gramine
## Prerequisites
### Install Slicer
Build the Slicer binary following the instructions in the Slicer installation guide.

Link: https://slicer.readthedocs.io/en/latest/developer_guide/build_instructions/linux.html

### Install Gramine
Install Gramine following the Gramine installation guide.

Link: https://gramine.readthedocs.io/en/latest/installation.html

## Running Slicer in Gramine

If your CPU doesn't support SGX, build the project using Intel SGX in simulation mode. 
This will generate a manifest file, which will be used during compilation with Gramine.
```
make SGX=SIM
```

Run slicer in gramine, without SGX support, using gramine-direct
```
gramine-direct Slicer
```