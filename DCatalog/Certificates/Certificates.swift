//
//  Certificates.swift
//  DCatalog
//
//  Created by Cornelis van der Bent on 14/01/2020.
//  Copyright © 2020 Digidentity B.V. All rights reserved.
//

import Foundation

/// Supply of available certificates.
///
/// Currently the certificate is stored in a file. To make is harder to replace this file (by iOS code injection or
/// patching the `.ipa`), the certificate could be added as a hard-coded string. See:
/// - https://medium.com/@kennethpoon/how-to-perform-ios-code-injection-on-ipa-files-1ba91d9438db
/// - https://github.com/Naituw/IPAPatch
///
/// The certificate file is retrieved using:
/// - `openssl s_client -connect marlove.net:443 </dev/null | openssl x509 -outform DER -out marlove.net.der`
struct Certificates
{
    static let marloveDotNet = Certificates.certificate(filename: "marlove.net")

    private static func certificate(filename: String) -> SecCertificate
    {
        let filePath = Bundle.main.path(forResource: filename, ofType: "der")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        let certificate = SecCertificateCreateWithData(nil, data as CFData)!

        return certificate
    }
}
