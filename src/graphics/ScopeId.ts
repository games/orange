module orange {
  export class ScopeId {
    name: string;
    private _value;
    versionObject: VersionedObject;

    constructor(name: string) {
      this.name = name;
      this.versionObject = new VersionedObject();
    }

    set value(value) {
      this._value = value;
      this.versionObject.increment();
    }

    get value () {
      return this._value;
    }
  }
}
