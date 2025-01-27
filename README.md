# (WIP) RV32I core
----
 - Modular, scalable design
	 + Compact core, designed as a soft core for FPGAs
 - Fully pipelined, fully scalar processor
	 + Planned Dual issue
	 + Planned basic instruction reordering
 - Zero latency branch prediction
	 + Planned BTB and return stack
 - Caching subsystem to hide memory latency
	 + Split L1i and L1d caches
		 * 4 bytes per cycle bandwidth
		 * 1 read port currently
		 * Planned second read port
		 * 32 entry
		 * Two way set associative, write through, write allocate*
		 * 1 cycle latency
	 + Unified L2 cache
		 * 1 write port
		 * Two read ports
		 * 256 entry
		 * direct mapped, write through, no write allocate*
		 * 4 cycle latency
 - Compact and embeddable core targeting FPGAs
 - Current support is Machine mode only

*We would like to have write back caches, however the ISA does not have support for `clwb` or similar. As such, all caches are write through to simplify memory mapped IO
