module orange {

  var idCounter = 0;

  export class VersionedObject {
    version: Version;
    constructor () {
      idCounter++;
      this.version = new Version();
      this.version.globalId = idCounter;
    }

    increment () {
      this.version.revision++;
    }
  }
}
