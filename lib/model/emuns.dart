enum VideoFormat { mov, avi, mkv, mp4, flv, wmv, rmvb, m4v, _3gp }

enum VideoQuality { _360P, _720P, _1080P, _2K, _4K, _8K }

enum ExecuteStatus {
  Idle,
  Executing,
  Success,
  Failed,
  Canceled,
  Paused,
  Stopped,
  Waiting,
  Completed,
  Unknown,
}
