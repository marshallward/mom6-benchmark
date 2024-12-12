MOM6 benchmark test
===================

To run the benchmark suite:

Update the submodule repositories::

   git submodule update --init --recursive

Run the benchmark test::

   cd benchmark_ALE
   mpirun -np 64 ../build/MOM6

Replace ``mpirun`` with your MPI library launcher.


MOM6 test suite
---------------

Optionally, run the self-consistency test suite::

   cd MOM6/.testing
   make -j
   make -j test

To run the profiler::

   make -j profile

To run the Linux perf-based profiler::

   make -j perf
