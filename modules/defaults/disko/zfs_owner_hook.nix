# Shell for a disko postMountHook that sets the owner of a dataset's root
# directory once, right after disko mounts it (so at installation). The
# ownership lives in the dataset from then on, so nothing has to re-assert it
# at boot or activation. Numeric uid:gid because the hook runs in the
# installer, where the owning user does not exist yet. disko wraps the
# key-load step in the same hooks, before anything is mounted, hence the guard.
{
  owner,
  mountpoint,
  rootMountPoint ? "/mnt",
}:
''
  if findmnt --mountpoint '${rootMountPoint}${mountpoint}' >/dev/null 2>&1; then
    chown ${owner} '${rootMountPoint}${mountpoint}'
  fi
''
