//
//  Blueprint.swift
//  Representor
//
//  Created by Kyle Fuller on 06/01/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import Foundation

// MARK: Models

public typealias Metadata = (name:String, value:String)

/// A structure representing an API Blueprint AST
public struct Blueprint {
  /// Name of the API
  public let name:String

  /// Top-level description of the API in Markdown (.raw) or HTML (.html)
  public let description:String?

  /// The collection of resource groups
  public let resourceGroups:[ResourceGroup]

  public let metadata:[Metadata]

  public init(name:String, description:String?, resourceGroups:[ResourceGroup]) {
    self.metadata = []
    self.name = name
    self.description = description
    self.resourceGroups = resourceGroups
  }

  public init(ast:[String:Any]) {
    metadata = parseMetadata(ast["metadata"] as? [[String:String]])
    name = ast["name"] as? String ?? ""
    description = ast["description"] as? String
    resourceGroups = parseBlueprintResourceGroups(ast)
  }

  public init?(named:String, bundle:Bundle? = nil) {
    func loadFile(_ named:String, bundle:Bundle) -> [String:Any]? {
      if let url = bundle.url(forResource: named, withExtension: nil) {
        if let data = try? Data(contentsOf: url) {
          let object: Any? = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as Any?
          return object as? [String:Any]
        }
      }

      return nil
    }

    let ast = loadFile(named, bundle: bundle ?? Bundle.main)
    if let ast = ast {
      self.init(ast: ast)
    } else {
      return nil
    }
  }
}

/// Logical group of resources.
public struct ResourceGroup {
  /// Name of the Resource Group
  public let name:String

  /// Description of the Resource Group (.raw or .html)
  public let description:String?

  /// Array of the respective resources belonging to the Resource Group
  public let resources:[Resource]

  public init(name:String, description:String?, resources:[Resource]) {
    self.name = name
    self.description = description
    self.resources = resources
  }
}

/// Description of one resource, or a cluster of resources defined by its URI template
public struct Resource {
  /// Name of the Resource
  public let name:String

  /// Description of the Resource (.raw or .html)
  public let description:String?

  /// URI Template as defined in RFC6570
  // TODO, make this a URITemplate object
  public let uriTemplate:String

  /// Array of URI parameters
  public let parameters:[Parameter]

  /// Array of actions available on the resource each defining at least one complete HTTP transaction
  public let actions:[Action]

  public let content:[[String:Any]]

  public init(name:String, description:String?, uriTemplate:String, parameters:[Parameter], actions:[Action], content:[[String:Any]]? = nil) {
    self.name = name
    self.description = description
    self.uriTemplate = uriTemplate
    self.actions = actions
    self.parameters = parameters
    self.content = content ?? []
  }
}

/// Description of one URI template parameter
public struct Parameter {
  /// Name of the parameter
  public let name:String

  /// Description of the Parameter (.raw or .html)
  public let description:String?

  /// An arbitrary type of the parameter (a string)
  public let type:String?

  /// Boolean flag denoting whether the parameter is required (true) or not (false)
  public let required:Bool

  /// A default value of the parameter (a value assumed when the parameter is not specified)
  public let defaultValue:String?

  /// An example value of the parameter
  public let example:String?

  /// An array enumerating possible parameter values
  public let values:[String]?

  public init(name:String, description:String?, type:String?, required:Bool, defaultValue:String?, example:String?, values:[String]?) {
    self.name = name
    self.description = description
    self.type = type
    self.required = required
    self.defaultValue = defaultValue
    self.example = example
    self.values = values
  }
}

// An HTTP transaction (a request-response transaction). Actions are specified by an HTTP request method within a resource
public struct Action {
  /// Name of the Action
  public let name:String

  /// Description of the Action (.raw or .html)
  public let description:String?

  /// HTTP request method defining the action
  public let method:String

  /// Array of URI parameters
  public let parameters:[Parameter]

  /// URI Template for the action, if it differs from the resource's URI
  public let uriTemplate:String?

  /// Link relation identifier of the action
  public let relation:String?

  /// HTTP transaction examples for the relevant HTTP request method
  public let examples:[TransactionExample]

  public let content:[[String:Any]]

  public init(name:String, description:String?, method:String, parameters:[Parameter], uriTemplate:String? = nil, relation:String? = nil, examples:[TransactionExample]? = nil, content:[[String:Any]]? = nil) {
    self.name = name
    self.description = description
    self.method = method
    self.parameters = parameters
    self.uriTemplate = uriTemplate
    self.relation = relation
    self.examples = examples ?? []
    self.content = content ?? []
  }
}

/// An HTTP transaction example with expected HTTP message request and response payload
public struct TransactionExample {
  /// Name of the Transaction Example
  public let name:String

  /// Description of the Transaction Example (.raw or .html)
  public let description:String?

  /// Example transaction request payloads
  public let requests:[Payload]

  /// Example transaction response payloads
  public let responses:[Payload]

  public init(name:String, description:String? = nil, requests:[Payload]? = nil, responses:[Payload]? = nil) {
    self.name = name
    self.description = description
    self.requests = requests ?? []
    self.responses = responses ?? []
  }
}


/// An API Blueprint payload.
public struct Payload {
  public typealias Header = (name:String, value:String)

  /// Name of the payload
  public let name:String

  /// Description of the Payload (.raw or .html)
  public let description:String?

  /// HTTP headers that are expected to be transferred with HTTP message represented by this payload
  public let headers:[Header]

  /// An entity body to be transferred with HTTP message represented by this payload
  public let body:Data?

  public let content:[[String:Any]]

  public init(name:String, description:String? = nil, headers:[Header]? = nil, body:Data? = nil, content:[[String:Any]]? = nil) {
    self.name = name
    self.description = description
    self.headers = headers ?? []
    self.body = body
    self.content = content ?? []
  }
}


// MARK: AST Parsing

func parseMetadata(_ source:[[String:String]]?) -> [Metadata] {
  if let source = source {
    return source.flatMap { item in
      if let name = item["name"] {
        if let value = item["value"] {
          return (name: name, value: value)
        }
      }

      return nil
    }
  }

  return []
}

func parseParameter(_ source:[[String:Any]]?) -> [Parameter] {
  if let source = source {
    return source.map { item in
      let name = item["name"] as? String ?? ""
      let description = item["description"] as? String
      let type = item["type"] as? String
      let required = item["required"] as? Bool
      let defaultValue = item["default"] as? String
      let example = item["example"] as? String
      let values = item["values"] as? [String]
      return Parameter(name: name, description: description, type: type, required: required ?? true, defaultValue: defaultValue, example: example, values: values)
    }
  }

  return []
}

func parseActions(_ source:[[String:Any]]?) -> [Action] {
  if let source = source {
    return source.flatMap { item in
      let name = item["name"] as? String
      let description = item["description"] as? String
      let method = item["method"] as? String
      let parameters = parseParameter(item["parameters"] as? [[String:Any]])
      let attributes = item["attributes"] as? [String:String]
      let uriTemplate = attributes?["uriTemplate"]
      let relation = attributes?["relation"]
      let examples = parseExamples(item["examples"] as? [[String:Any]])
      let content = item["content"] as? [[String:Any]]

      if let name = name {
        if let method = method {
          return Action(name: name, description: description, method: method, parameters: parameters, uriTemplate:uriTemplate, relation:relation, examples:examples, content:content)
        }
      }

      return nil
    }
  }

  return []
}

func parseExamples(_ source:[[String:Any]]?) -> [TransactionExample] {
  if let source = source {
    return source.flatMap { item in
      let name = item["name"] as? String
      let description = item["description"] as? String
      let requests = parsePayloads(item["requests"] as? [[String:Any]])
      let responses = parsePayloads(item["responses"] as? [[String:Any]])

      if let name = name {
        return TransactionExample(name: name, description: description, requests: requests, responses: responses)
      }

      return nil
    }
  }

  return []
}

func parsePayloads(_ source:[[String:Any]]?) -> [Payload] {
  if let source = source {
    return source.flatMap { item in
      let name = item["name"] as? String
      let description = item["description"] as? String
      let headers = parseHeaders(item["headers"] as? [[String:String]])
      let bodyString = item["body"] as? String
      let body = bodyString?.data(using: String.Encoding.utf8, allowLossyConversion: true)
      let content = item["content"] as? [[String:Any]]

      if let name = name {
        return Payload(name: name, description: description, headers: headers, body: body, content: content)
      }

      return nil
    }
  }

  return []
}

func parseHeaders(_ source:[[String:String]]?) -> [Payload.Header] {
  if let source = source {
    return source.flatMap { item in
      if let name = item["name"], let value = item["value"] {
        return (name, value)
      }

      return nil
    }
  }

  return []
}

func parseResources(_ source:[[String:Any]]?) -> [Resource] {
  if let source = source {
    return source.flatMap { item in
      let name = item["name"] as? String
      let description = item["description"] as? String
      let uriTemplate = item["uriTemplate"] as? String
      let actions = parseActions(item["actions"] as? [[String:Any]])
      let parameters = parseParameter(item["parameters"] as? [[String:Any]])
      let content = item["content"] as? [[String:Any]]

      if let name = name, let uriTemplate = uriTemplate {
        return Resource(name: name, description: description, uriTemplate: uriTemplate, parameters: parameters, actions: actions, content: content)
      }

      return nil
    }
  }

  return []
}

private func parseBlueprintResourceGroups(_ blueprint:[String:Any]) -> [ResourceGroup] {
  if let resourceGroups = blueprint["resourceGroups"] as? [[String:Any]] {
    return resourceGroups.flatMap { dictionary in
      if let name = dictionary["name"] as? String {
        let resources = parseResources(dictionary["resources"] as? [[String:Any]])
        let description = dictionary["description"] as? String
        return ResourceGroup(name: name, description: description, resources: resources)
      }

      return nil
    }
  }

  return []
}
