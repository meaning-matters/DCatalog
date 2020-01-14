//
//  WebItemSource.swift
//  DCatalog
//
//  Created by Cornelis van der Bent on 12/01/2020.
//  Copyright © 2020 Digidentity B.V. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

private let authenticationToken = "5adafeffbbb51b7178d69601bbe67149"
private let basePath = "https://marlove.net/e/mock/v1/"

// Alomofire adapter for adding the authentication token to each web API call.
private class WebApiRequestAdapter : RequestAdapter
{
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void)
    {
        var adaptedRequest = urlRequest
        adaptedRequest.headers.add(name: "Authorization", value: authenticationToken)

        completion(.success(adaptedRequest))
    }
}

/// RESTful web API implementation of the remote item catalog.
class WebItemSource : ItemSource
{
    private var session: Session

    // Because SSL pinning does not work (the certificate is both untrusted and the CN is not marlove.net), this allows
    // easy disabling and selecting evaluation method.
    private let doSslPinning: Bool = false
    private let doPublicKeyPinning: Bool = false

    /// Creates a `WebItemSource` object.
    init()
    {
        let adapter = WebApiRequestAdapter()
        let interceptor = Interceptor(adapters: [adapter])
        if doSslPinning
        {
            var evaluator: ServerTrustEvaluating
            if doPublicKeyPinning
            {
                evaluator = PublicKeysTrustEvaluator(keys: [Certificates.marloveDotNet.af.publicKey!],
                                                     performDefaultValidation: true,
                                                     validateHost: true)
            }
            else
            {
                evaluator = PinnedCertificatesTrustEvaluator(certificates: [Certificates.marloveDotNet],
                                                             acceptSelfSignedCertificates: true,
                                                             performDefaultValidation: true,
                                                             validateHost: true)
                evaluator = PinnedCertificatesTrustEvaluator(certificates: [Certificates.marloveDotNet])
            }

            let server = URL(string: basePath)!.host!
            let serverTrustManager = ServerTrustManager(evaluators: [ server : evaluator ])
            session = Session(interceptor: interceptor, serverTrustManager: serverTrustManager)
        }
        else
        {
            session = Session(interceptor: interceptor)
        }
    }

    func retrieveItems(sinceId: String? = nil, maxId: String? = nil, completion: @escaping([ItemModel]?, Error?) -> Void)
    {
        var parameters = [String : String]()
        sinceId != nil ? parameters["since_id"] = sinceId : nil
        maxId != nil ? parameters["max_id"] = maxId : nil

        let request = session.request(basePath + "items", method: .get,
                                      parameters: parameters,
                                      encoder: URLEncodedFormParameterEncoder.default) // Adds parameters to URL.
        request.responseDecodable(of: [ItemModel].self)
        { (response) in
            completion(response.value, response.error)
        }
    }

    // TODO: Implement and test.
    func addItem(imageBase64: String, text: String, confidence: Float, completion: @escaping(String?, Error?) -> Void)
    {
        let parameters = ["image" : imageBase64, "text" : text, "confidence" : "\(confidence)"]

        let request = session.request(basePath + "item", method: .post,
                                      parameters: parameters,
                                      encoder: JSONParameterEncoder.default) // Places parameters in JSON body.
        request.responseJSON
        { (response) in
            // TODO: Get server generated `id` from `response`.
            let id = "12345678"
            completion(id, response.error)
        }
    }

    func deleteItem(id: String, completion: @escaping(Error?) -> Void)
    {
        let request = session.request(basePath + "item/\(id)", method: .delete)
        request.response
        { (response) in
            print(response)
            completion(response.error)
        }
    }

    // TODO: implement and test.
    func deleteAllItems(completion: @escaping(Error?) -> Void)
    {
        let request = session.request(basePath + "item", method: .delete)
        request.response
        { (response) in
            completion(response.error)
        }
    }
}
