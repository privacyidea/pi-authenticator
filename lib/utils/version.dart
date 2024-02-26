class Version implements Comparable<Version> {
  final int major;
  final int minor;
  final int patch;

  const Version(this.major, this.minor, this.patch);

  /// Parses a [version] string and returns a [Version] object.
  /// Throws a [FormatException] if the input string is not a valid version.
  /// Examples of accepted strings: "1.0.0", "0.0.1", "0.0.0"
  factory Version.parse(String version) {
    final parts = version.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid version: $version');
    }
    return Version(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  @override
  operator ==(other) {
    if (other is! Version) return false;
    return major == other.major && minor == other.minor && patch == other.patch;
  }

  operator <(other) {
    if (other is! Version) {
      return false;
    }
    if (major != other.major) {
      if (major < other.major) return true;
      return false;
    }
    if (minor != other.minor) {
      if (minor < other.minor) return true;
      return false;
    }
    if (patch != other.patch) {
      if (patch < other.patch) return true;
      return false;
    }
    return false;
  }

  operator >(other) {
    if (other is! Version) return false;
    if (major != other.major) {
      if (major > other.major) return true;
      return false;
    }
    if (minor != other.minor) {
      if (minor > other.minor) return true;
      return false;
    }
    if (patch != other.patch) {
      if (patch > other.patch) return true;
      return false;
    }
    return false;
  }

  operator <=(other) {
    if (other is! Version) return false;
    if (major > other.major) return false;
    if (minor > other.minor) return false;
    if (patch > other.patch) return false;
    return true;
  }

  operator >=(other) {
    if (other is! Version) return false;
    if (major < other.major) return false;
    if (minor < other.minor) return false;
    if (patch < other.patch) return false;
    return true;
  }

  @override
  int compareTo(Version other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  @override
  String toString() => '$major.$minor.$patch';

  @override
  int get hashCode {
    int hash = 17;
    hash = hash * 31 + major.hashCode;
    hash = hash * 31 + minor.hashCode;
    hash = hash * 31 + patch.hashCode;
    return hash;
  }
}
