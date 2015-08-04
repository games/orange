module orange {
  export class Version {
    globalId = 0;
    revision = 0;

    equals (other: Version) {
      return this.globalId === other.globalId &&
             this.revision === other.revision;
    }

    notequals (other: Version) {
      return this.globalId !== other.globalId ||
             this.revision !== other.revision;
    }

    copy (other: Version) {
      this.globalId = other.globalId;
      this.revision = other.revision;
    }

    reset () {
      this.globalId = 0;
      this.revision = 0;
    }
  }
}
