//
//  Graph.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 07.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import DVB


struct Edge: Codable, Hashable {
    let origin: Stop
    let destination: Stop
    var weight: Int = 1
    
    private enum CodingKeys: String, CodingKey {
        case originId
        case originName
        case originRegion
        case originLocation
        case destinationId
        case destinationName
        case destinationRegion
        case destinationLocation
        case weight
    }
    
    init(origin: Stop, destination: Stop, weight: Int = 1) {
        self.origin = origin
        self.destination = destination
        self.weight = weight
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let originId = try values.decode(String.self, forKey: .originId)
        let originName = try values.decode(String.self, forKey: .originName)
        let originRegion = try values.decode(String?.self, forKey: .originRegion)
        let originLocation = try values.decode(WGSCoordinate?.self, forKey: .originLocation)
        origin = Stop(id: originId, name: originName, region: originRegion, location: originLocation)
        let destinationId = try values.decode(String.self, forKey: .destinationId)
        let destinationName = try values.decode(String.self, forKey: .destinationName)
        let destinationRegion = try values.decode(String?.self, forKey: .destinationRegion)
        let destinationLocation = try values.decode(WGSCoordinate?.self, forKey: .destinationLocation)
        destination = Stop(id: destinationId, name: destinationName, region: destinationRegion, location: destinationLocation)
        weight = try values.decode(Int.self, forKey: .weight)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(origin.id, forKey: .originId)
        try container.encode(origin.name, forKey: .originName)
        try container.encode(origin.region, forKey: .originRegion)
        try container.encode(origin.location, forKey: .originLocation)
        try container.encode(destination.id, forKey: .destinationId)
        try container.encode(destination.name, forKey: .destinationName)
        try container.encode(destination.region, forKey: .destinationRegion)
        try container.encode(destination.location, forKey: .destinationLocation)
        try container.encode(weight, forKey: .weight)
    }
    
    mutating func strengthen() {
        weight += 1
    }
}


struct RouteGraph: Codable {
    var edges: [Edge] = []
    var endpoint: Stop? = nil
    
    public static var main: RouteGraph {
        get {
            guard
                let data = UserDefaults.standard.object(forKey: "graph") as? Data,
                let graph = try? JSONDecoder().decode(RouteGraph.self, from: data)
            else {return RouteGraph()}
            return graph
        }
        set {
            let data = try! JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: "graph")
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case edges
        case endpointId
        case endpointName
        case endpointRegion
        case endpointLocation
    }

    init(edges: [Edge] = [], endpoint: Stop? = nil) {
        self.edges = edges
        self.endpoint = endpoint
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        edges = try values.decode([Edge].self, forKey: .edges)
        let endpointId = try values.decode(String.self, forKey: .endpointId)
        let endpointName = try values.decode(String.self, forKey: .endpointName)
        let endpointRegion = try values.decode(String?.self, forKey: .endpointRegion)
        let location = try values.decode(WGSCoordinate?.self, forKey: .endpointLocation)
        endpoint = Stop(id: endpointId, name: endpointName, region: endpointRegion, location: location)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(edges, forKey: .edges)
        try container.encode(endpoint?.id, forKey: .endpointId)
        try container.encode(endpoint?.name, forKey: .endpointName)
        try container.encode(endpoint?.region, forKey: .endpointRegion)
        try container.encode(endpoint?.location, forKey: .endpointLocation)
    }
    
    public mutating func visit(stop: Stop) {
        
        var newEdge: Edge
        if let endpoint = endpoint {
            newEdge = Edge(origin: endpoint, destination: stop)
        } else {
            newEdge = Edge(origin: stop, destination: stop)
        }
        
        for (i, edge) in edges.enumerated() {
            if edge.origin == newEdge.origin && edge.destination == newEdge.destination {
                edges[i].strengthen()
                endpoint = stop
                return
            }
        }
        edges.append(newEdge)
        endpoint = stop
    }
    
    public func getStopSuggestions() -> [Stop] {
        guard let endpoint = endpoint else {return []}
        return edges
            .filter {$0.origin == endpoint}
            .sorted {$0.weight > $1.weight}
            .map {$0.destination}
    }
}
