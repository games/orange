module orange {

  interface StringMap<T> {
    [key: string]: T;
  }

  export class ScopeSpace {
    variables: StringMap<ScopeId>;
    namespaces: StringMap<ScopeSpace>;

    constructor(public name: string) {
      this.variables = {};
      this.namespaces = {};
    }

    resolve(name: string) {
      if (this.variables.hasOwnProperty(name) === false) {
        this.variables[name] = new ScopeId(name);
      }
      return this.variables[name];
    }

    getSubSpace(name: string) {
      if (this.namespaces.hasOwnProperty(name) === false) {
          this.namespaces[name] = new ScopeSpace(name);
      }
      return this.namespaces[name];
    }
  }
}
