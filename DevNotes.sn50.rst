


problem running 

gpu and non gpu node
**^ tin n0259.savio3 /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/mrbayes/3.2.7a ^**>
singularity run --nv mrBayes_1119.sif

Singularity> mpirun
X Error of failed request:  BadRequest (invalid request code or no such operation)
  Major opcode of failed request:  153 (DRI2)
  Minor opcode of failed request:  1 (DRI2Connect)
  Serial number of failed request:  11
  Current serial number in output stream:  11
Singularity> pwd
/opt/beagle-lib/build
Singularity> mb
X Error of failed request:  BadRequest (invalid request code or no such operation)
  Major opcode of failed request:  153 (DRI2)
  Minor opcode of failed request:  1 (DRI2Connect)
  Serial number of failed request:  11
  Current serial number in output stream:  11
Singularity>



BUT ...

[tin@exalearn5 ~]$ docker run --rm    ghcr.io/tin6150/mrbayes:docker-sn50 <<< "showbeagle"
works.   
show begle 4.0.0 (pre-lrease), this is from the compiled source.
no need for the apt pkg, which is 3.1.2


~~~~~

the illegal instruction remains a problem.
strace...
somewhere , oh maybe log (from make)
found that it was  using -Davx... some instructions that is not avail in n0060, 259 or ln000
so maybe that optimization avail in cloud server not avail locally...
BUT i thought binary have alternate version avail embeded so it can run?
it worked as docker on another test machine (which only have avx2 and no avx512 anything!)

for now, still disabled mpi and see
but unlikely a problem, as earlier build worked, albeit on a vanilla ubuntu base rather that nvidia with CUDA.
there are omplain about oopencl-icd...

nompi still result in "Illegal instructions"

maybe just have beagle with cpu and mpi...
nope, wonder if it is the CUDA libary and/or driver mismatch from the base image... 

**^ tin ln000.brc /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/mrbayes/3.2.7a ^**>  ./mrBayes_1121_beagle312_noopencl.sif
Illegal instruction
	which is rather strange, since BEAST2 used the cuda11.4.2 image and worked.


2022_1122
reverted back to use vanilla ubuntu:focal as base, 
on master, still get Illegal instruction, even the mb-serial fails.
and even on n0060 fails.
it is cuz it needs to find a gpu!  cuz cpu, icelake, works on 259, not n60

n259>
	on gpu node 259, A40, icelake 6326, mb starts, gpu doesn't work, but maybe mpi could, at least withnin node?
	[root@n0259.savio3 /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/mrbayes/3.2.7a]# ./mrBayes_1122_ubu_beagle312.sif
	beignet-opencl-icd: no supported GPU found, this is probably the wrong opencl-icd package for this hardware
	(If you have multiple ICDs installed and OpenCL works, you can ignore this message)
	beignet-opencl-icd: no supported GPU found, this is probably the wrong opencl-icd package for this hardware
	(If you have multiple ICDs installed and OpenCL works, you can ignore this message)
	beignet-opencl-icd: no supported GPU found, this is probably the wrong opencl-icd package for this hardware
	(If you have multiple ICDs installed and OpenCL works, you can ignore this message)
	--------------------------------------------------------------------------
	By default, for Open MPI 4.0 and later, infiniband ports on a device
	are not used by default.  The intent is to use UCX for these devices.
	You can override this policy by setting the btl_openib_allow_ib MCA parameter
	to true.
	  Local host:              n0259
	  Local adapter:           mlx5_0
	  Local port:              1
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	WARNING: There was an error initializing an OpenFabrics device.
	  Local host:   n0259
	  Local device: mlx5_0
	--------------------------------------------------------------------------
								MrBayes 3.2.7a x86_64
								 (Parallel version)
							 (1 processors available)
	MrBayes > showbeagle
	beignet-opencl-icd: no supported GPU found, this is probably the wrong opencl-icd package for this hardware
	(If you have multiple ICDs installed and OpenCL works, you can ignore this message)
	OpenCL error: CL_DEVICE_NOT_FOUND from file <GPUInterfaceOpenCL.cpp>, line 122.


or
	[root@n0259.savio3 /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/mrbayes/3.2.7a]# singularity run --nv ./mrBayes_1122_ubu_beagle312.sif
	beignet-opencl-icd: no supported GPU found, this is probably the wrong opencl-icd package for this hardware
	(If you have multiple ICDs installed and OpenCL works, you can ignore this message)

n259-c>
	**^ tin n0259.savio3 ~/gs/fc_graham/PRISA/Assemblies/anim66/PROKKA ^**>  singularity exec --nv /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/mrbayes/3.2.7a/./mrBayes_1122_ubu_beagle312.sif /opt/MrBayes/src/mb-serial mb_anim66itv.nex
	both mb and mb-serial works on n0259, much quicker than n0004, and it is not using gpu (don't see anyting per nvidia-smi)

n4:
	**^ tin n0004.savio3 ~/gs/fc_graham/PRISA/Assemblies/anim66/PROKKA ^**>  singularity exec --nv /clusterfs/vector/home/groups/software/sl-7.x86_64/modules/mrbayes/3.2.7a/./mrBayes_1122_ubu_beagle312.sif /opt/MrBayes/src/mb-serial mb_anim66itv.nex
	serial version works, but default mb wants to poke at gpu, get error, then fails (even when it could try cpu code, as n0259 did)
		does any of this affect docker on exa5 ?!
	default mb would essentially poke at gpu and barf with obscure error that now is clearly GPU related:
		X Error of failed request:  BadRequest (invalid request code or no such operation)
		  Major opcode of failed request:  153 (DRI2)
		  Minor opcode of failed request:  1 (DRI2Connect)
		  Serial number of failed request:  11
		  Current serial number in output stream:  11

