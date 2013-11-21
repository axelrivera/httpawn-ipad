//
//  NSData+RestClient.m
//  RestClient
//
//  Created by Axel Rivera on 8/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "NSData+RestClient.h"

@implementation NSData (Kumo)

- (NSString *)stringWithEncoding:(NSStringEncoding)encoding
{
    NSString *string = [[NSString alloc] initWithData:self
                                             encoding:encoding];
    return string;
}

//- (NSString *)XMLStringWithEncoding:(NSStringEncoding)encoding
//{
//    NSError *error;
//     *document = [[NSXMLDocument alloc] initWithXMLString:[self stringWithEncoding:encoding]
//                                                               options:NSXMLDocumentTidyXML
//                                                                 error:&error];
//    NSString *string = [document XMLStringWithOptions:0];
//    return string;
//}
//
//- (NSString *)formattedXMLStringWithEncoding:(NSStringEncoding)encoding
//{
//    NSError *error;
//    NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:[self stringWithEncoding:encoding]
//                                                               options:NSXMLDocumentTidyXML
//                                                                 error:&error];
//    NSString *string = [document XMLStringWithOptions:NSXMLNodePrettyPrint];
//    return string;
//}

- (id)JSONObject
{
    return [NSJSONSerialization JSONObjectWithData:self options:0 error:nil];
}

- (NSString *)JSONStringWithEncoding:(NSStringEncoding)encoding
{
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:[self JSONObject] options:0 error:nil];
    NSString *string = [JSONData stringWithEncoding:encoding];
    return string;
}

- (NSString *)formattedJSONStringWithEncoding:(NSStringEncoding)encoding
{
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:[self JSONObject] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *string = [JSONData stringWithEncoding:encoding];
    return string;
}

@end
