# Network Attached Storage with Samba

Storing files locally on each node will clash with the principle of using a load balancer, as the files will become inaccessible when a user is proxied to another worker node. To avoid this scenario, files must be stored in a central location. In an ideal environment a service like AWS S3 is used for that.

For demonstration purposes, we'll setup a network attached storage drive. That drive will be used by all nodes for file storage.

The drive will be attached to the manager node. In a production-grade environment a RAID setup should be used to avoid data loss in the case of failing hard drives.

## Samba Server Setup

"Samba is a free software re-implementation of the SMB networking protocol [...]. Samba provides file and print services for various Microsoft Windows clients and can integrate with a Microsoft Windows Server domain, either as a Domain Controller (DC) or as a domain member. As of version 4, it supports Active Directory and Microsoft Windows NT domains." (From: [Samba (software) - Wikipedia](https://en.wikipedia.org/wiki/Samba_(software))).

In short Samba provides features for Linux machines, which are otherwise only available on Windows machines. The feature we want to make use of is to serve files on the network. More precisely we want to share a directory on the network which will be used as the central file storage mentioned earlier.

To setup that directory, follow the steps below.

### 1. Install `samba`

```shell
sudo apt install samba
```

### 2. Open the following ports (done with `ufw` in the example)

```shell
sudo ufw allow 137/udp comment "Samba"
sudo ufw allow 138/udp comment "Samba"
sudo ufw allow 139/tcp comment "Samba"
sudo ufw allow 445/tcp comment "Samba"
```

See https://www.samba.org/~tpot/articles/firewall.html for reference.

### 3. Create a new user

```shell
sudo useradd --shell /sbin/nologin send
```

This creates a new user called `send` with the shell `/sbin/nologin`.
That's actually not a shell, just a program which prints an information saying
the current account may not use a shell or login.

Change the name to your likings.

### 4. Create a data directory in the user's home directory

```
sudo -H -u send sh -c 'mkdir ~/data'
```

What `-H` does (from `man sudo.8`):
> Request that the security policy set the HOME environment variable to the home directory specified by the target user's password database entry.

Also see [here](https://askubuntu.com/a/338449/566120) for more information.

### 5. Add the user to samba's internal user database

```shell
sudo smbpasswd -a send
```

### 6. Modify the `samba` config

Modify the file `smb.conf.example` and append the contents to `/etc/samba/smb.conf`.

### 7. Restart `samba`

```shell
sudo systemctl restart smbd
```

### 8. Test

On another device, run the following command to test the connection to the new samba share:

```shell
smbclient -L //<IP or DNS NAME>
```

*Tip*: Remove the `<` and `>` ;)

The output should contain the following line:

```
Sharename       Type      Comment
---------       ----      -------
...             ...       ...
send_storage    Disk      Send Storage
```

Then try to open a connection to the share:

```shell
smbclient -U send //<IP or DNS NAME>/send_storage
```

You'll be prompted for the password you set in step 5. A shell-like environment should appear. Type `exit` to leave the shell.

## Automounting the share on worker nodes

Now that the directory share is setup, other nodes can mount the directory into their filesystem.

### 1. Install dependencies

In order to mount samba shares onto linux machines, the package `cifs-utils` is required. Install it using `apt`:

```shell
sudo apt install cifs-utils
```

### 2. Persist the credentials on the filesystem

In order to be able to auto-mount the directory share, the credentials must be available on each worker node. Create a file called `.smb_credentials` somewhere on the worker node (e.g. in `/home/pi`) with the following content:

```properties
user=send
password=
domain=WORKGROUP
```

Fill in the password created in step 5 of the last chapter.

### 3. Edit `/etc/fstab`

Append the following line to `/etc/fstab`:

```
# send storage
//pi-cluster-main/send_storage /mnt/send_storage cifs uid=0,credentials=/home/pi/.smb_credentials,iocharset=utf8,noperm 0 0
```

Used options (from `man mount.cifs(8)`):

- `uid=0`: specifies the ID of the user who will own the files in the mounted directory in case the share server does not provide any ownership information. The ID `0` is always associated to the `root` user.

- `credentials=/home/pi/.smb_credentials`: specifies the file to read the login credentials from.

- `iocharset=utf8`: The charset used to convert local path names to and from Unicode.

- `noperm`: Disabled permission checks by the client (client = worker node).

### 4. Mount the share

Reboot the worker node or type the following:

```shell
sudo mount -a
```

Then validate the operation by listing all mounted drives:

```shell
mount
```

The output should contain a line similar to the following:

```
//<IP OR DNS NAME>/send_storage on /mnt/send_storage type cifs (...)
```

Now try to create a file in `/mnt/send_storage` and check the directory on the manager node (where the samba server is running). If the created file appears there too, everything is working.

## Further steps

My own experiments taught me that mounted samba shared are susceptible for random disconnects without notification.
There are mechanisms to re-establish the connection, but still: using a service like AWS S3 (or MinIO, a selfhosted S3) or even a real NAS system is less prone to such problems
