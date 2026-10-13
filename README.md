# Log Archive Tool (`log-archive`)

A lightweight, robust command-line utility written in Bash to compress and archive log directories, assign timestamped versions, and maintain an automated audit log of all archive operations.

---

## Features

- **Dynamic Source Path**: Archives any specified log directory via command-line arguments.
- **Safe Archival**: Excludes unnecessary nested folder structures using `tar -C`.
- **Gzip Compression**: Compresses logs into lightweight `.tar.gz` archives.
- **Timestamped Versioning**: Names archives using the standard `logs_archive_YYYYMMDD_HHMMSS.tar.gz` format to prevent collisions.
- **Execution Audit Logging**: Tracks timestamp, archive filename, file size, and source directory in a dedicated log file (`archive_history.log`).
- **Defensive Shell Scripting**: Built with strict mode (`set -euo pipefail`) and parameter expansion to prevent runtime failures.

---

## Requirements

- Unix-like environment (Linux / macOS / WSL)
- Standard GNU utilities: `bash`, `tar`, `gzip`, `awk`, `date`, `du`
- Root / `sudo` privileges (if archiving system directories like `/var/log`)

---

## Project Structure

```text
.
├── log-archive.sh       # Main executable shell script
├── README.md            # Project documentation

```

---

## Installation

1. **Clone or create the script file**:
   Save your script as `log-archive.sh`.

2. **Grant execution permissions**:

   ```bash
   chmod +x log-archive.sh
   ```

3. **Install globally (Optional)**:
   Create a symlink to `/usr/local/bin` to run the tool from any working directory:
   ```bash
   sudo ln -sf "$(pwd)/log-archive.sh" /usr/local/bin/log-archive
   ```

---

## Usage

### Syntax

```bash
log-archive <log-directory>
```

### Examples

**Archiving a custom application log directory:**

```bash
log-archive /path/to/my-app/logs
```

**Archiving system logs (requires elevated privileges):**

```bash
sudo log-archive /var/log
```

### Testing Locally

You can safely test the tool using a temporary directory:

```bash
# 1. Create a mock directory with dummy log files
mkdir -p /tmp/mock_logs
echo "Sample access log entry" > /tmp/mock_logs/access.log
echo "Sample error log entry" > /tmp/mock_logs/error.log

# 2. Run the archiver
./log-archive.sh /tmp/mock_logs

# 3. Inspect the archive contents without extracting
tar -tvf /var/log_archive/logs_archive_*.tar.gz
```

---

## How It Works

1. **Input Validation**: Checks if the directory argument was provided (`${1:-}`) and confirms the directory exists (`[ -d "$LOG_DIR" ]`).
2. **Path & Name Generation**: Formats the current time using `date +"%Y%m%d_%H%M%S"` to construct the archive filename.
3. **Packaging with `tar`**:

   ```bash
   tar -czf "$ARCHIVE_PATH" -C "$LOG_DIR" .
   ```

   - `-c`: Create a new archive.
   - `-z`: Compress using Gzip.
   - `-f`: Specify the output file path.
   - `-C "$LOG_DIR"`: Changes working directory to the target before compression (ensuring clean relative paths inside the archive).
   - `.`: Tells `tar` to pack all files and subdirectories in the working directory.

4. **Audit History Recording**: Extracts archive size via `du -h ... | awk '{print $1}'` and appends an execution record to `archive_history.log`.

---

## Automation (Cron Job)

To automatically run the archive utility on a recurring schedule, add it to your system crontab:

```bash
sudo crontab -e
```

**Run every day at midnight:**

```cron
0 0 * * * /usr/local/bin/log-archive /var/log >> /var/log_archive/cron_output.log 2>&1
```

**Run weekly (Sundays at 02:00 AM):**

```cron
0 2 * * 0 /usr/local/bin/log-archive /var/log >> /var/log_archive/cron_output.log 2>&1
```

---

## Future Improvements

- [ ] Add an optional `--retention <days>` flag to auto-delete archives older than $N$ days.
- [ ] Add remote backup synchronization via `rsync` or cloud object storage (`aws s3 cp`).
- [ ] Send alert notifications via email, Slack webhook, or Discord on failure.
