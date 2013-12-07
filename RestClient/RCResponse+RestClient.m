//
//  RCResponse+RestClient.m
//  RestClient
//
//  Created by Axel Rivera on 12/6/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RCResponse+RestClient.h"

#define kRCLangKey          @"language"
#define kRCCodeKey          @"code"
#define kRCPrettyPrintKey   @"pretty_print"
#define kRCLineNumbersKey   @"line_numbers"
#define kRCSHKey            @"syntax_highlighting"

#define kRCLangText         @"text"
#define kRCLangXML          @"xml"
#define kRCLangJSON         @"json"

@implementation RCResponse (RestClient)

- (NSString *)formattedHTMLBodyString
{
    NSNumber *prettyPrint = [NSNumber numberWithBool:[[RCSettings defaultSettings] usePrettyPrintResponse]];
    NSNumber *applySyntaxHighlighting = [NSNumber numberWithBool:[[RCSettings defaultSettings] applySyntaxHighlighting]];
    NSNumber *includeLineNumbers = [NSNumber numberWithBool:[[RCSettings defaultSettings] includeLineNumbers]];
    
    NSMutableDictionary *dictionary = [@{ kRCPrettyPrintKey : prettyPrint,
                                          kRCSHKey : applySyntaxHighlighting,
                                          kRCLineNumbersKey : includeLineNumbers,
                                          kRCCodeKey : [self rawString] } mutableCopy];
    
    NSString *bodyStr = @"";
    if ([self isJSON]) {
        dictionary[kRCLangKey] = kRCLangJSON;
        bodyStr = [[self class] formattedJSONHTMLStringWithDictionary:dictionary];
    } else if ([self isXML]) {
        dictionary[kRCLangKey] = kRCLangXML;
        bodyStr = [[self class] formattedXMLHTMLStringWithDictionary:dictionary];
    } else {
        bodyStr = [self formattedRawBodyString];
    }
    
    return bodyStr;
}

- (NSString *)formattedRawBodyString
{
    NSString *code = [[self class] stringWithEscapedHTMLCharactersFromString:[self rawString]];
    NSString *bodyStr =
    @"<body class=\"raw_content\">"
    "<pre>"
    "%@"
    "</pre"
    "</body>";
    
    NSString *body = [NSString stringWithFormat:bodyStr, code];
    
    return [[self class] htmlDocumentWithScript:nil
                                         body:body];
}

+ (NSString *)htmlDocumentWithScript:(NSString *)script body:(NSString *)body
{
    if (IsEmpty(script)) {
        script = @"";
    }
    
    NSString *headStr =
    @"<head>"
    "<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />"
    "<link href=\"prettify.css\" type=\"text/css\" rel=\"stylesheet\" />"
    "<script type=\"text/javascript\" src=\"prettify.js\"></script>"
    "<script type=\"text/javascript\" src=\"vkbeautify.js\"></script>"
    "<style>"
    "body { margin: 5px; padding: 0; word-wrap: break-word; font-family: \"Lucida Console\", Monaco, monospace; font-size: 0.9em }"
    "body.raw_content { }"
    "pre { margin: 0; }"
    "</style>"
    "%@"
    "</head>";
    
    NSString *head = [NSString stringWithFormat:headStr, script];

    if (IsEmpty(body)) {
        body = @"<body></body>";
    }

    NSString *string = @"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\""
    " \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"
    "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">"
    "%@"
    "%@"
    "</html>";

    return [NSString stringWithFormat:string, head, body];
}

+ (NSString *)formattedJSONHTMLStringWithDictionary:(NSDictionary *)dictionary
{
    NSString *script =
    @"<script>"
    "function beautify() {"
    "var mycode = document.getElementById('mycode');"
    "mycode.innerHTML = vkbeautify.json(mycode.innerHTML, 2);"
    "}"
    "</script>";
    
    BOOL prettyPrint = IsEmpty(dictionary[kRCPrettyPrintKey]) ? NO : [dictionary[kRCPrettyPrintKey] boolValue];
    BOOL includeLineNumbers = IsEmpty(dictionary[kRCLineNumbersKey]) ? NO : [dictionary[kRCLineNumbersKey] boolValue];
    NSString *codeStr = IsEmpty(dictionary[kRCCodeKey]) ? @"" : dictionary[kRCCodeKey];
    BOOL applySyntaxHighlighting = IsEmpty(dictionary[kRCSHKey]) ? NO : [dictionary[kRCSHKey] boolValue];
    
    NSString *onloadStr = @"";
    NSString *prettyClassStr = @"";
    NSString *lineNumStr = @"";
    if (prettyPrint) {
        if (applySyntaxHighlighting) {
            onloadStr = @"beautify();prettyPrint();";
            prettyClassStr = @"prettyprint";
            if (includeLineNumbers) {
                lineNumStr = @"<?prettify linenums=1?>";
            }
        } else {
            onloadStr = @"beautify();";
            prettyClassStr = @"";
        }
    } else {
        if (applySyntaxHighlighting) {
            onloadStr = @"prettyPrint();";
            prettyClassStr = @"prettyprint";
            if (includeLineNumbers) {
                lineNumStr = @"<?prettify linenums=1?>";
            }
        } else {
            onloadStr = @"";
        }
    }
    
    NSString *bodyStr =
    @"<body onload=\"%@\">"
    "<?prettify lang=%@?>"
    "%@"
    "<pre style=\"border:none; margin: 5px; padding: 0px;\" id=\"mycode\" class=\"%@\">"
    "%@"
    "</pre>"
    "</body>";
    
    NSString *body = [NSString stringWithFormat:bodyStr,
                      onloadStr,
                      kRCLangJSON,
                      lineNumStr,
                      prettyClassStr,
                      codeStr];
    
    return [[self class] htmlDocumentWithScript:script body:body];
}

+ (NSString *)formattedXMLHTMLStringWithDictionary:(NSDictionary *)dictionary
{
    NSString *script =
    @"<script>"
    "function escapeHtml(text) {"
    "return text"
    ".replace(/&/g, \"&amp;\")"
    ".replace(/</g, \"&lt;\")"
    ".replace(/>/g, \"&gt;\")"
    ".replace(/\"/g, \"&quot;\")"
    ".replace(/'/g, \"&#039\")"
    "}"
    "function unescapeHtml(text) {"
    "return text"
    ".replace(/&amp;/g, \"&\")"
    ".replace(/&lt;/g, \"<\")"
    ".replace(/&gt;/g, \">\")"
    ".replace(/&quot;/g, \"\\\"\")"
    ".replace(/&#039;/g, \"'\");"
    "}"
    "function beautify() {"
    "var mycode = document.getElementById('mycode');"
    "var text = unescapeHtml(mycode.innerHTML);"
    "mycode.innerHTML = escapeHtml(vkbeautify.xml(text, 2));"
    "}"
    "</script>";
    
    BOOL prettyPrint = IsEmpty(dictionary[kRCPrettyPrintKey]) ? NO : [dictionary[kRCPrettyPrintKey] boolValue];
    BOOL includeLineNumbers = IsEmpty(dictionary[kRCLineNumbersKey]) ? NO : [dictionary[kRCLineNumbersKey] boolValue];
    NSString *langStr = IsEmpty(dictionary[kRCLangKey]) ? kRCLangText : dictionary[kRCLangKey];
    NSString *codeStr = IsEmpty(dictionary[kRCCodeKey]) ? @"" : dictionary[kRCCodeKey];
    BOOL applySyntaxHighlighting = IsEmpty(dictionary[kRCSHKey]) ? NO : [dictionary[kRCSHKey] boolValue];
    
    NSString *onloadStr = @"";
    NSString *prettyClassStr = @"";
    NSString *lineNumStr = @"";
    if (prettyPrint) {
        if (applySyntaxHighlighting) {
            onloadStr = @"beautify();prettyPrint()";
            prettyClassStr = @"prettyprint";
            if (includeLineNumbers) {
                lineNumStr = @"<?prettify linenums=1?>";
            }
        } else {
            onloadStr = @"beautify();";
            prettyClassStr = @"";
        }
    } else {
        if (applySyntaxHighlighting) {
            onloadStr = @"prettyPrint();";
            prettyClassStr = @"prettyprint";
            if (includeLineNumbers) {
                lineNumStr = @"<?prettify linenums=1?>";
            }
        } else {
            onloadStr = @"";
        }
    }
    
    NSString *bodyStr =
    @"<body onload=\"%@\">"
    "<?prettify lang=%@?>"
    "%@"
    "<pre style=\"border:none;\" id=\"mycode\" class=\"%@\">"
    "%@"
    "</pre>"
    "</body>";
    
    NSString *body = [NSString stringWithFormat:bodyStr,
                      onloadStr,
                      langStr,
                      lineNumStr,
                      prettyClassStr,
                      [[self class] stringWithEscapedHTMLCharactersFromString:codeStr]];
    
    return [[self class] htmlDocumentWithScript:script body:body];
}

+ (NSString *)stringWithEscapedHTMLCharactersFromString:(NSString *)string
{
    NSDictionary *characters = @{ @"<" : @"&lt;", @">" : @"&gt;", @"\\\"" : @"&quot;", @"'" : @"&#039;" };
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    [characters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [mutableString replaceOccurrencesOfString:key
                                       withString:obj
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, [mutableString length])];
    }];
    return mutableString;
}

- (NSString *)stringWithUnescapedHTMLCharacterfFromString:(NSString *)string
{
    NSDictionary *characters = @{ @"&lt;" : @"<", @"&gt;" : @">", @"&quot;" : @"\\\"", @"&#039;" : @"'" };
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    [characters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [mutableString replaceOccurrencesOfString:key
                                       withString:obj
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, [mutableString length])];
    }];
    return mutableString;
}

@end
