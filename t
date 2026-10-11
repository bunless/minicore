[1m// os: operating system features and the local filesystem[m
[1m// [m
[1m// The os module provides access to resources from the host operating system,[m
[1m// particularly to the filesystem and standard I/O. [[cwd]] provides an[m
[1m// implementation of [[fs::fs]] which is backed by the host filesystem, and this[m
[1m// module provides equivalents of various [[fs::]] functions which infer the[m
[1m// current working directory as the fs parameter. This module also provides various[m
[1m// non-filesystem related features from the host, such as the hostname, environment[m
[1m// variables, and so on.[m

[1m// Submodules
// - [[os::exec::]] command execution and process management
[m
[1m//[m[1m Access modes for [[access]].[m[1m
[m[94mtype[m [0mamode[m [1m=[m [96menum[m [0m{[m
	[0mF_OK[m [1m=[m [0mrt[m[0m::[m[0mF_OK[m[0m,[m
	[0mR_OK[m [1m=[m [0mrt[m[0m::[m[0mR_OK[m[0m,[m
	[0mW_OK[m [1m=[m [0mrt[m[0m::[m[0mW_OK[m[0m,[m
	[0mX_OK[m [1m=[m [0mrt[m[0m::[m[0mX_OK[m[0m,[m
[0m}[m[0m;[m
[m
[1m//[m[1m All currently supported target architectures. This enum will be extended[m[1m
[m[1m//[m[1m whenever support for a new architecture is added.[m[1m
[m[94mtype[m [0march[m [1m=[m [96menum[m [0m{[m
	[0mAARCH64[m[0m,[m
	[0mRISCV64[m[0m,[m
	[0mX86_64[m[0m,[m
[0m}[m[0m;[m
[m
[1m//[m[1m Flags for the [[mlock]] family of operations.[m[1m
[m[94mtype[m [0mmcl[m [1m=[m [96menum[m [96muint[m [0m{[m
	[0mCURRENT[m [1m=[m [95m1[m[0m,[m
	[0mFUTURE[m [1m=[m [95m2[m[0m,[m
	[0mONFAULT[m [1m=[m [95m4[m[0m,[m
[0m}[m[0m;[m
[m
[1m//[m[1m Flags for [[memfd]].[m[1m
[m[94mtype[m [0mmemfd_flag[m [1m=[m [96menum[m [96muint[m [0m{[m
	[0mNONE[m [1m=[m [95m0[m[0m,[m
	[0mNOCLOEXEC[m [1m=[m [0mrt[m[0m::[m[0mMFD_CLOEXEC[m[0m,[m [1m//[m[1m Unsets the close-on-exec flag when creating a memfd.[m[1m
[m	[0mALLOW_SEALING[m [1m=[m [0mrt[m[0m::[m[0mMFD_ALLOW_SEALING[m[0m,[m [1m//[m[1m Allows sealing operations on this file.[m[1m
[m	[0mHUGETLB[m [1m=[m [0mrt[m[0m::[m[0mMFD_HUGETLB[m[0m,[m [1m//[m[1m Create the memfd with huge pages using hugetlbfs. Linux-only.[m[1m
[m[0m}[m[0m;[m
[m
[1m//[m[1m Controls how symlinks are followed (or not) in a dirfd filesystem. Support[m[1m
[m[1m//[m[1m for this feature varies, you should gate usage of this enum behind a build[m[1m
[m[1m//[m[1m tag.[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m Note that on Linux, specifying BENEATH or IN_ROOT will also disable magic[m[1m
[m[1m//[m[1m symlinks.[m[1m
[m[94mtype[m [0mresolve_flag[m [1m=[m [96menum[m [96mu64[m [0m{[m
	[0mNORMAL[m [1m=[m [95m0[m[0m,[m
[1m	[m[1m//[m[1m Does not allow symlink resolution to occur for any symlinks which[m[1m
[m[1m	[m[1m//[m[1m would refer to any anscestor of the fd directory. This disables all[m[1m
[m[1m	[m[1m//[m[1m absolute symlinks, and any call to open or create with an absolute[m[1m
[m[1m	[m[1m//[m[1m path.[m[1m
[m	[0mBENEATH[m [1m=[m [0mrt[m[0m::[m[0mRESOLVE_BENEATH[m [1m|[m [0mrt[m[0m::[m[0mRESOLVE_NO_MAGICLINKS[m[0m,[m
[1m	[m[1m//[m[1m Treat the directory fd as the root directory. This affects[m[1m
[m[1m	[m[1m//[m[1m open/create for absolute paths, as well as absolute path resolution[m[1m
[m[1m	[m[1m//[m[1m of symlinks. The effects are similar to chroot.[m[1m
[m	[0mIN_ROOT[m [1m=[m [0mrt[m[0m::[m[0mRESOLVE_IN_ROOT[m [1m|[m [0mrt[m[0m::[m[0mRESOLVE_NO_MAGICLINKS[m[0m,[m
	[0mNO_SYMLINKS[m [1m=[m [0mrt[m[0m::[m[0mRESOLVE_NO_SYMLINKS[m[0m,[m [1m//[m[1m Disables symlink resolution entirely.[m[1m
[m[1m	[m[1m//[m[1m Disallows traversal of mountpoints during path resolution. This is[m[1m
[m[1m	[m[1m//[m[1m not recommended for general use, as bind mounts are extensively used[m[1m
[m[1m	[m[1m//[m[1m on many systems.[m[1m
[m	[0mNO_XDEV[m [1m=[m [0mrt[m[0m::[m[0mRESOLVE_NO_XDEV[m[0m,[m
[0m}[m[0m;[m
[m
[1m//[m[1m Values that may be passed to [[exit]] to indicate successful or unsuccessful[m[1m
[m[1m//[m[1m termination, respectively.[m[1m
[m[94mtype[m [0mstatus[m [1m=[m [96menum[m [0m{[m
	[0mSUCCESS[m [1m=[m [95m0[m[0m,[m
	[0mFAILURE[m [1m=[m [95m1[m[0m,[m
[0m}[m[0m;[m
[m
[1m//[m[1m The recommended buffer size for reading from disk.[m[1m
[m[94mdef[m [0mBUFSZ[m[0m:[m [96msize[m [1m=[m [95m4096[m[0m;[m
[m
[1m//[m[1m The command line arguments provided to the program. By convention, the first[m[1m
[m[1m//[m[1m member is usually the name of the program.[m[1m
[m[94mlet[m [0margs[m[0m:[m [96m[[m[96m][m[96mstr[m[0m;[m
[m
[1m//[m[1m Provides an implementation of [[fs::fs]] for the current working directory.[m[1m
[m[94mlet[m [0mcwd[m[0m:[m [96m*[m[96mfs[m[96m::[m[96mfs[m[0m;[m
[m
[1m//[m[1m The standard error. This handle is unbuffered.[m[1m
[m[94mlet[m [0mstderr[m[0m:[m [96mio[m[96m::[m[96mhandle[m[0m;[m
[m
[1m//[m[1m The standard error, as an [[io::file]]. This handle is unbuffered.[m[1m
[m[94mlet[m [0mstderr_file[m[0m:[m [96mio[m[96m::[m[96mfile[m[0m;[m
[m
[1m//[m[1m The standard input. This handle is buffered.[m[1m
[m[94mlet[m [0mstdin[m[0m:[m [96mio[m[96m::[m[96mhandle[m[0m;[m
[m
[1m//[m[1m The standard input, as an [[io::file]]. This handle is unbuffered.[m[1m
[m[94mlet[m [0mstdin_file[m[0m:[m [96mio[m[96m::[m[96mfile[m[0m;[m
[m
[1m//[m[1m The standard output. This handle is buffered.[m[1m
[m[94mlet[m [0mstdout[m[0m:[m [96mio[m[96m::[m[96mhandle[m[0m;[m
[m
[1m//[m[1m The standard output, as an [[io::file]]. This handle is unbuffered.[m[1m
[m[94mlet[m [0mstdout_file[m[0m:[m [96mio[m[96m::[m[96mfile[m[0m;[m
[m
[1m//[m[1m Returns true if the given mode of access is permissible. The use of this[m[1m
[m[1m//[m[1m function is discouraged as it can allow for a race condition to occur betwen[m[1m
[m[1m//[m[1m testing for the desired access mode and actually using the file should the[m[1m
[m[1m//[m[1m permissions of the file change between these operations. It is recommended[m[1m
[m[1m//[m[1m instead to attempt to use the file directly and to handle any errors that[m[1m
[m[1m//[m[1m should occur at that time.[m[1m
[m[94mfn[m [0maccess[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m,[m [0mmode[m[0m:[m [96mamode[m[0m)[m [96m([m[96mbool[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Returns a portable string for an [[arch]].[m[1m
[m[94mfn[m [0march_name[m[0m([m[0march[m[0m:[m [96march[m[0m)[m [96mstr[m[0m;[m
[m
[1m//[m[1m Returns the host CPU architecture.[m[1m
[m[94mfn[m [0marchitecture[m[0m([m[0m)[m [96march[m[0m;[m
[m
[1m//[m[1m Change the current working directory.[m[1m
[m[94mfn[m [0mchdir[m[0m([m[0mtarget[m[0m:[m [96m([m[96m*[m[96mfs[m[96m::[m[96mfs[m [96m|[m [96mstr[m[96m)[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Changes mode flags on a file or directory. Type bits are discared.[m[1m
[m[94mfn[m [0mchmod[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m,[m [0mmode[m[0m:[m [96mfs[m[96m::[m[96mmode[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Changes ownership of a file.[m[1m
[m[94mfn[m [0mchown[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m,[m [0muid[m[0m:[m [96muint[m[0m,[m [0mgid[m[0m:[m [96muint[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Changes the root directory of the process. Generally requires the caller to[m[1m
[m[1m//[m[1m have root or otherwise elevated permissions.[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m This function is not appropriate for sandboxing.[m[1m
[m[94mfn[m [0mchroot[m[0m([m[0mtarget[m[0m:[m [96mstr[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Changes the access and modification time of a file. A void value will leave[m[1m
[m[1m//[m[1m the corresponding time unchanged.[m[1m
[m[94mfn[m [0mchtimes[m[0m(
[m[0m	path[m[0m:[m [96mstr[m[0m,
[m[0m	atime[m[0m:[m [96m([m[96mtime[m[96m::[m[96minstant[m [96m|[m [96mvoid[m[96m)[m[0m,
[m[0m	mtime[m[0m:[m [96m([m[96mtime[m[96m::[m[96minstant[m [96m|[m [96mvoid[m[96m)[m[0m,
)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Returns the number of usable CPUs.[m[1m
[m[94mfn[m [0mcpucount[m[0m([m[0m)[m [96m([m[96msize[m [96m|[m [96merrors[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Creates a new file with the given mode if it doesn't already exist and opens[m[1m
[m[1m//[m[1m it for writing.[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m Only the permission bits of the mode are used. If other bits are set, they[m[1m
[m[1m//[m[1m are discarded.[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m The return value is an unbuffered [[io::file]]. For buffered I/O, see[m[1m
[m[1m//[m[1m [[create_buffered]]. To create a file without opening it, see [[mkfile]].[m[1m
[m[94mfn[m [0mcreate[m[0m(
[m[0m	path[m[0m:[m [96mstr[m[0m,
[m[0m	mode[m[0m:[m [96mfs[m[96m::[m[96mmode[m[0m,
[m[0m	flags[m[0m:[m [96mfs[m[96m::[m[96mflag[m [0m=[m [0mfs[m[0m::[m[0mflag[m[0m::[m[0mWRONLY[m [1m|[m [0mfs[m[0m::[m[0mflag[m[0m::[m[0mTRUNC[m[0m,
)[m [96m([m[96mio[m[96m::[m[96mfile[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Creates a new file with the given mode if it doesn't already exist and opens[m[1m
[m[1m//[m[1m it for writing, allocating read and/or write buffers for buffered I/O. To[m[1m
[m[1m//[m[1m open an unbuffered [[io::file]] see [[create]].[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m Only the permission bits of the mode are used. If other bits are set, they[m[1m
[m[1m//[m[1m are discarded.[m[1m
[m[94mfn[m [0mcreate_buffered[m[0m(
[m[0m	path[m[0m:[m [96mstr[m[0m,
[m[0m	mode[m[0m:[m [96mfs[m[96m::[m[96mmode[m[0m,
[m[0m	flags[m[0m:[m [96mfs[m[96m::[m[96mflag[m [0m=[m [0mfs[m[0m::[m[0mflag[m[0m::[m[0mWRONLY[m [1m|[m [0mfs[m[0m::[m[0mflag[m[0m::[m[0mTRUNC[m[0m,
)[m [96m([m[96mbufio[m[96m::[m[96mstream[m [96m|[m [96mfs[m[96m::[m[96merror[m [96m|[m [96mnomem[m[96m)[m[0m;[m
[m
[1m//[m[1m Sets the buffer size to use with the getdents(2) system call, for use with[m[1m
[m[1m//[m[1m [[fs::iter]]. A larger buffer requires a larger runtime allocation, but can[m[1m
[m[1m//[m[1m scan large directories faster. The default buffer size is 32 KiB.[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m This function is not portable.[m[1m
[m[94mfn[m [0mdirfdfs_set_getdents_bufsz[m[0m([m[0mfs[m[0m:[m [96m*[m[96mfs[m[96m::[m[96mfs[m[0m,[m [0msz[m[0m:[m [96msize[m[0m)[m [96mvoid[m[0m;[m
[m
[1m//[m[1m Opens a file descriptor as an [[fs::fs]]. This file descriptor must be a[m[1m
[m[1m//[m[1m directory file. The file will be closed when the fs is closed.[m[1m
[m[94mfn[m [0mdirfdopen[m[0m(
[m[0m	fd[m[0m:[m [96mio[m[96m::[m[96mfile[m[0m,
[m[0m	resolve_flags[m[0m:[m [96mresolve_flag[m [0m=[m [0mresolve_flag[m[0m::[m[0mNORMAL[m[0m,
)[m [96m*[m[96mfs[m[96m::[m[96mfs[m[0m;[m
[m
[1m//[m[1m Returns an [[io::file]] for this filesystem. This function is not portable.[m[1m
[m[94mfn[m [0mdirfile[m[0m([m[0mfs[m[0m:[m [96m*[m[96mfs[m[96m::[m[96mfs[m[0m)[m [96mio[m[96m::[m[96mfile[m[0m;[m
[m
[1m//[m[1m Clones a dirfd filesystem, optionally adding additional [[resolve_flag]][m[1m
[m[1m//[m[1m constraints.[m[1m
[m[94mfn[m [0mdirfs_clone[m[0m(
[m[0m	fs[m[0m:[m [96m*[m[96mfs[m[96m::[m[96mfs[m[0m,
[m[0m	resolve_flags[m[0m:[m [96mresolve_flag[m [0m=[m [0mresolve_flag[m[0m::[m[0mNORMAL[m[0m,
)[m [96m*[m[96mfs[m[96m::[m[96mfs[m[0m;[m
[m
[1m//[m[1m Opens a directory as a filesystem.[m[1m
[m[94mfn[m [0mdiropen[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m)[m [96m([m[96m*[m[96mfs[m[96m::[m[96mfs[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Returns true if a node exists at the given path, or false if not.[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m Note that testing for file existence before using the file can often lead to[m[1m
[m[1m//[m[1m race conditions. If possible, prefer to simply attempt to use the file (e.g.[m[1m
[m[1m//[m[1m via "open"), and handle the resulting error should the file not exist.[m[1m
[m[94mfn[m [0mexists[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m)[m [96mbool[m[0m;[m
[m
[1m//[m[1m Exit the program with the provided status code.[m[1m
[m[94mfn[m [0mexit[m[0m([m[0mstatus[m[0m:[m [96mint[m[0m)[m [96mnever[m[0m;[m
[m
[1m//[m[1m Changes mode flags on a [[io::file]]. Type bits are discared.[m[1m
[m[94mfn[m [0mfchmod[m[0m([m[0mfd[m[0m:[m [96mio[m[96m::[m[96mfile[m[0m,[m [0mmode[m[0m:[m [96mfs[m[96m::[m[96mmode[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Changes ownership of a [io::file]].[m[1m
[m[94mfn[m [0mfchown[m[0m([m[0mfd[m[0m:[m [96mio[m[96m::[m[96mfile[m[0m,[m [0muid[m[0m:[m [96muint[m[0m,[m [0mgid[m[0m:[m [96muint[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Changes the access and modification time of an [[io::file]]. A void value[m[1m
[m[1m//[m[1m will leave the corresponding time unchanged.[m[1m
[m[94mfn[m [0mfchtimes[m[0m(
[m[0m	fd[m[0m:[m [96mio[m[96m::[m[96mfile[m[0m,
[m[0m	atime[m[0m:[m [96m([m[96mtime[m[96m::[m[96minstant[m [96m|[m [96mvoid[m[96m)[m[0m,
[m[0m	mtime[m[0m:[m [96m([m[96mtime[m[96m::[m[96minstant[m [96m|[m [96mvoid[m[96m)[m[0m,
)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Returns file information for an [[io::file]].[m[1m
[m[94mfn[m [0mfstat[m[0m([m[0mfd[m[0m:[m [96mio[m[96m::[m[96mfile[m[0m)[m [96m([m[96mfs[m[96m::[m[96mfilestat[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Returns the current working directory. The return value is statically[m[1m
[m[1m//[m[1m allocated and must be duplicated (see [[strings::dup]]) before calling getcwd[m[1m
[m[1m//[m[1m again.[m[1m
[m[94mfn[m [0mgetcwd[m[0m([m[0m)[m [96mstr[m[0m;[m
[m
[1m//[m[1m Looks up an environment variable and returns its value, or void if unset.[m[1m
[m[94mfn[m [0mgetenv[m[0m([m[0mname[m[0m:[m [96mstr[m[0m)[m [96m([m[96mstr[m [96m|[m [96mvoid[m[96m)[m[0m;[m
[m
[1m//[m[1m Returns a slice of the environment strings in the form KEY=VALUE.[m[1m
[m[94mfn[m [0mgetenvs[m[0m([m[0m)[m [96m[[m[96m][m[96mstr[m[0m;[m
[m
[1m//[m[1m Returns the [[fs::flag]]s associated with a file descriptor. See fcntl(2),[m[1m
[m[1m//[m[1m ref F_GETFL.[m[1m
[m[94mfn[m [0mgetflags[m[0m([m[0mfile[m[0m:[m [96mio[m[96m::[m[96mfile[m[0m)[m [96m([m[96mfs[m[96m::[m[96mflag[m [96m|[m [96merrors[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Gets an extended file attribute.[m[1m
[m[1m//[m[1m The caller is responsible for freeing the returned slice.[m[1m
[m[94mfn[m [0mgetxattr[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m,[m [0mname[m[0m:[m [96mstr[m[0m)[m [96m([m[96m[[m[96m][m[96mu8[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Returns the host system hostname.[m[1m
[m[94mfn[m [0mhostname[m[0m([m[0m)[m [96mstr[m[0m;[m
[m
[1m//[m[1m Creates an [[fs::iterator]] for a given directory to read its contents. The[m[1m
[m[1m//[m[1m order in which entries are returned is undefined. The user should call[m[1m
[m[1m//[m[1m [[fs::next]] to enumerate entries, and [[fs::finish]] when done iterating.[m[1m
[m[94mfn[m [0miter[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m)[m [96m([m[96m*[m[96mfs[m[96m::[m[96miterator[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Creates a new (hard) link at 'new' for the file at 'old'.[m[1m
[m[94mfn[m [0mlink[m[0m([m[0mold[m[0m:[m [96mstr[m[0m,[m [0mnew[m[0m:[m [96mstr[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Returns the host CPU architecture, in a platform-specific format. See[m[1m
[m[1m//[m[1m [[architecture]] for a more portable wrapper.[m[1m
[m[94mfn[m [0mmachine[m[0m([m[0m)[m [96mstr[m[0m;[m
[m
[1m//[m[1m Creates a new anonymous [[io::file]] backed by memory.[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m The initial file size is zero. It can be written to normally, or the size can[m[1m
[m[1m//[m[1m be set manually with [[io::trunc]].[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m This function is available on Linux and FreeBSD.[m[1m
[m[94mfn[m [0mmemfd[m[0m(
[m[0m	name[m[0m:[m [96mstr[m[0m,
[m[0m	flags[m[0m:[m [96mmemfd_flag[m [0m=[m [0mmemfd_flag[m[0m::[m[0mNONE[m[0m,
)[m [96m([m[96mio[m[96m::[m[96mfile[m [96m|[m [96merrors[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Makes a block device node. This function is only available on Unix-like[m[1m
[m[1m//[m[1m systems.[m[1m
[m[94mfn[m [0mmkblk[m[0m(
[m[0m	path[m[0m:[m [96mstr[m[0m,
[m[0m	mode[m[0m:[m [96mfs[m[96m::[m[96mmode[m[0m,
[m[0m	major[m[0m:[m [96muint[m[0m,
[m[0m	minor[m[0m:[m [96muint[m[0m,
)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Makes a character device node. This function is only available on Unix-like[m[1m
[m[1m//[m[1m systems.[m[1m
[m[94mfn[m [0mmkchr[m[0m(
[m[0m	path[m[0m:[m [96mstr[m[0m,
[m[0m	mode[m[0m:[m [96mfs[m[96m::[m[96mmode[m[0m,
[m[0m	major[m[0m:[m [96muint[m[0m,
[m[0m	minor[m[0m:[m [96muint[m[0m,
)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Creates a directory.[m[1m
[m[94mfn[m [0mmkdir[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m,[m [0mmode[m[0m:[m [96mfs[m[96m::[m[96mmode[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Creates a directory, and all non-extant directories in its path.[m[1m
[m[94mfn[m [0mmkdirs[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m,[m [0mmode[m[0m:[m [96mfs[m[96m::[m[96mmode[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Makes a FIFO node. This function is only available on Unix systems.[m[1m
[m[94mfn[m [0mmkfifo[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m,[m [0mmode[m[0m:[m [96mfs[m[96m::[m[96mmode[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Makes a regular file. This function is only available on Unix-like systems.[m[1m
[m[1m//[m[1m This function should only be used if you have a special reason; most of the[m[1m
[m[1m//[m[1m time you should use [[create]] instead.[m[1m
[m[94mfn[m [0mmkfile[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m,[m [0mmode[m[0m:[m [96mfs[m[96m::[m[96mmode[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Locks a region of memory so that it will not be written to swap.[m[1m
[m[94mfn[m [0mmlock[m[0m([m[0maddr[m[0m:[m [96m*[m[96mopaque[m[0m,[m [0mlength[m[0m:[m [96msize[m[0m,[m [0mflags[m[0m:[m [96mmcl[m[0m)[m [96m([m[96mvoid[m [96m|[m [96merrors[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Locks the entire process's address space so that it will not be written to[m[1m
[m[1m//[m[1m swap.[m[1m
[m[94mfn[m [0mmlockall[m[0m([m[0mflags[m[0m:[m [96mmcl[m[0m)[m [96m([m[96mvoid[m [96m|[m [96merrors[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Moves a file. This will use [[rename]] if possible, and will fall back to[m[1m
[m[1m//[m[1m copy and remove if necessary.[m[1m
[m[94mfn[m [0mmove[m[0m([m[0moldpath[m[0m:[m [96mstr[m[0m,[m [0mnewpath[m[0m:[m [96mstr[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Unlocks memory previously locked with [[mlock]].[m[1m
[m[94mfn[m [0mmunlock[m[0m([m[0maddr[m[0m:[m [96m*[m[96mopaque[m[0m,[m [0mlength[m[0m:[m [96msize[m[0m)[m [96m([m[96mvoid[m [96m|[m [96merrors[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Unlocks all locked memory in the process's address space.[m[1m
[m[94mfn[m [0mmunlockall[m[0m([m[0m)[m [96m([m[96mvoid[m [96m|[m [96merrors[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Opens a file.[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m [[fs::flag::CREATE]] isn't very useful with this function, since the new[m[1m
[m[1m//[m[1m file's mode is set to zero. For this use-case, use [[create]] instead.[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m The return value is an unbuffered [[io::file]]. For buffered I/O, see[m[1m
[m[1m//[m[1m [[open_buffered]].[m[1m
[m[94mfn[m [0mopen[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m,[m [0mflags[m[0m:[m [96mfs[m[96m::[m[96mflag[m [0m=[m [0mfs[m[0m::[m[0mflag[m[0m::[m[0mRDONLY[m[0m)[m [96m([m[96mio[m[96m::[m[96mfile[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Opens a file and allocates read and/or write buffers for buffered I/O. To[m[1m
[m[1m//[m[1m open an unbuffered [[io::file]] see [[open]].[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m [[fs::flag::CREATE]] isn't very useful with this function, since the new[m[1m
[m[1m//[m[1m file's mode is set to zero. For this use-case, use [[create]] instead.[m[1m
[m[94mfn[m [0mopen_buffered[m[0m(
[m[0m	path[m[0m:[m [96mstr[m[0m,
[m[0m	flags[m[0m:[m [96mfs[m[96m::[m[96mflag[m [0m=[m [0mfs[m[0m::[m[0mflag[m[0m::[m[0mRDONLY[m[0m,
)[m [96m([m[96mbufio[m[96m::[m[96mstream[m [96m|[m [96mfs[m[96m::[m[96merror[m [96m|[m [96mnomem[m[96m)[m[0m;[m
[m
[1m//[m[1m Reads all entries from a directory. The caller must free the return value[m[1m
[m[1m//[m[1m with [[fs::dirents_free]].[m[1m
[m[94mfn[m [0mreaddir[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m)[m [96m([m[96m[[m[96m][m[96mfs[m[96m::[m[96mdirent[m [96m|[m [96mfs[m[96m::[m[96merror[m [96m|[m [96mnomem[m[96m)[m[0m;[m
[m
[1m//[m[1m Returns the path referred to by a symbolic link. The return value is[m[1m
[m[1m//[m[1m statically allocated and will be overwritten on subsequent calls.[m[1m
[m[94mfn[m [0mreadlink[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m)[m [96m([m[96mstr[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Canonicalizes a path in this filesystem by resolving all symlinks and[m[1m
[m[1m//[m[1m collapsing any "." or ".." path components.[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m This function is a thin shim over [[fs::realpath]], and the return value is[m[1m
[m[1m//[m[1m statically allocated by [[fs::realpath]]. Thus, calls to this function or to[m[1m
[m[1m//[m[1m [[fs::realpath]] will overwrite the return value of either function.[m[1m
[m[94mfn[m [0mrealpath[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m)[m [96m([m[96mstr[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Returns the host kernel version.[m[1m
[m[94mfn[m [0mrelease[m[0m([m[0m)[m [96mstr[m[0m;[m
[m
[1m//[m[1m Removes a file.[m[1m
[m[94mfn[m [0mremove[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Removes an extended file attribute.[m[1m
[m[94mfn[m [0mremovexattr[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m,[m [0mname[m[0m:[m [96mstr[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Renames a file. This generally only works if the source and destination path[m[1m
[m[1m//[m[1m are both on the same filesystem. See [[move]] for an implementation which[m[1m
[m[1m//[m[1m falls back on a "copy & remove" procedure in this situation.[m[1m
[m[94mfn[m [0mrename[m[0m([m[0moldpath[m[0m:[m [96mstr[m[0m,[m [0mnewpath[m[0m:[m [96mstr[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Resolves a path to its absolute, normalized value. Relative paths will be[m[1m
[m[1m//[m[1m rooted (if supported by the host filesystem), and "." and ".." components[m[1m
[m[1m//[m[1m will be reduced. This function does not follow symlinks; see [[realpath]] if[m[1m
[m[1m//[m[1m you need this behavior. The return value is statically allocated; use[m[1m
[m[1m//[m[1m [[strings::dup]] to extend its lifetime.[m[1m
[m[94mfn[m [0mresolve[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m)[m [96mstr[m[0m;[m
[m
[1m//[m[1m Removes a directory. The target directory must be empty; see [[rmdirall]] to[m[1m
[m[1m//[m[1m remove its contents as well.[m[1m
[m[94mfn[m [0mrmdir[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Removes a directory, and anything in it.[m[1m
[m[94mfn[m [0mrmdirall[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Sets an environment variable, overwriting it if it's already set. The name[m[1m
[m[1m//[m[1m may not contain '=' or '\0', and the value may not contain '\0'.[m[1m
[m[94mfn[m [0msetenv[m[0m([m[0mname[m[0m:[m [96mstr[m[0m,[m [0mvalue[m[0m:[m [96mstr[m[0m)[m [96m([m[96mvoid[m [96m|[m [96merrors[m[96m::[m[96minvalid[m [96m|[m [96mnomem[m[96m)[m[0m;[m
[m
[1m//[m[1m Sets the [[fs::flag]]s associated with a file descriptor. Changes to the[m[1m
[m[1m//[m[1m access mode (e.g. [[fs::flag::RDWR]] and file creation flags (e.g.[m[1m
[m[1m//[m[1m [[fs::flag::CREATE]]) are ignored. See fcntl(2), ref F_SETFL.[m[1m
[m[94mfn[m [0msetflags[m[0m([m[0mfile[m[0m:[m [96mio[m[96m::[m[96mfile[m[0m,[m [0mflags[m[0m:[m [96mfs[m[96m::[m[96mflag[m[0m)[m [96m([m[96mvoid[m [96m|[m [96merrors[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Sets an extended file attribute.[m[1m
[m[94mfn[m [0msetxattr[m[0m(
[m[0m	path[m[0m:[m [96mstr[m[0m,
[m[0m	name[m[0m:[m [96mstr[m[0m,
[m[0m	value[m[0m:[m [96m[[m[96m][m[96mu8[m[0m,
[m[0m	flags[m[0m:[m [96msetxattr_flag[m [0m=[m [0msetxattr_flag[m[0m::[m[0mNONE[m[0m,
)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Opens (or creates, given [[fs::flag::CREATE]]) a global shared memory file[m[1m
[m[1m//[m[1m with the given name, suitable for use with [[io::mmap]] to establish shared[m[1m
[m[1m//[m[1m memory areas with other processes using the same name.[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m The name must not contain any forward slashes (one is permissible at the[m[1m
[m[1m//[m[1m start, e.g. "/example") and cannot be "." or "..".[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m The "oflag" parameter, if provided, must include either [[fs::flag::RDONLY]][m[1m
[m[1m//[m[1m or [[fs::flag::RDWR]], and may optionally add [[fs::flag::CREATE]],[m[1m
[m[1m//[m[1m [[fs::flag::EXCL]], and/or [[fs::flag::TRUNC]], other flags are silently[m[1m
[m[1m//[m[1m ignored if set.[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m The new file descriptor always has CLOEXEC set regardless of the provided[m[1m
[m[1m//[m[1m flags. If creating a new shared memory object, set its initial size with[m[1m
[m[1m//[m[1m [[io::trunc]] before mapping it with [[io::mmap]].[m[1m
[m[1m//[m[1m[m[1m
[m[1m//[m[1m Call [[shm_unlink]] to remove the global shared memory object.[m[1m
[m[94mfn[m [0mshm_open[m[0m(
[m[0m	name[m[0m:[m [96mstr[m[0m,
[m[0m	oflag[m[0m:[m [96mfs[m[96m::[m[96mflag[m [0m=[m [0mfs[m[0m::[m[0mflag[m[0m::[m[0mCREATE[m [1m|[m [0mfs[m[0m::[m[0mflag[m[0m::[m[0mRDWR[m[0m,
[m[0m	mode[m[0m:[m [96mfs[m[96m::[m[96mmode[m [0m=[m [95m384[m[0m,
)[m [96m([m[96mio[m[96m::[m[96mfile[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Removes the shared memory object with the given name. Processes which already[m[1m
[m[1m//[m[1m hold a reference to the file may continue to use the memory associated with[m[1m
[m[1m//[m[1m it. Once all processes have unmapped the associated shared memory object, or[m[1m
[m[1m//[m[1m exited, the memory is released.[m[1m
[m[94mfn[m [0mshm_unlink[m[0m([m[0mname[m[0m:[m [96mstr[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Returns file information for a given path. If the target is a symlink,[m[1m
[m[1m//[m[1m information is returned about the link, not its target.[m[1m
[m[94mfn[m [0mstat[m[0m([m[0mpath[m[0m:[m [96mstr[m[0m)[m [96m([m[96mfs[m[96m::[m[96mfilestat[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Creates a new symbolic link at 'path' which points to 'target'.[m[1m
[m[94mfn[m [0msymlink[m[0m([m[0mtarget[m[0m:[m [96mstr[m[0m,[m [0mpath[m[0m:[m [96mstr[m[0m)[m [96m([m[96mvoid[m [96m|[m [96mfs[m[96m::[m[96merror[m[96m)[m[0m;[m
[m
[1m//[m[1m Returns the host kernel name.[m[1m
[m[94mfn[m [0msysname[m[0m([m[0m)[m [96mstr[m[0m;[m
[m
[1m//[m[1m Looks up an environment variable and returns its value, or a default value if[m[1m
[m[1m//[m[1m unset.[m[1m
[m[94mfn[m [0mtryenv[m[0m([m[0mname[m[0m:[m [96mstr[m[0m,[m [0mdefault[m[0m:[m [96mstr[m[0m)[m [96mstr[m[0m;[m
[m
[1m//[m[1m Unsets an environment variable. Does nothing if the variable isn't set. The[m[1m
[m[1m//[m[1m name may not contain '=' or '\0'.[m[1m
[m[94mfn[m [0munsetenv[m[0m([m[0mname[m[0m:[m [96mstr[m[0m)[m [96m([m[96mvoid[m [96m|[m [96merrors[m[96m::[m[96minvalid[m[96m)[m[0m;[m
[m
[1m//[m[1m Returns the host operating system version.[m[1m
[m[94mfn[m [0mversion[m[0m([m[0m)[m [96mstr[m[0m;[m
