//
//  JHEmojiManager.m
//  JHKit
//
//  Created by HaoCold on 2017/12/14.
//  Copyright © 2017年 HaoCold. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2017 xjh093
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "JHEmojiManager.h"

@interface JHEmojiManager()
@property (nonatomic,  strong) NSString *file;
@property (nonatomic,  strong) NSDictionary *emojiDic;
@end

@implementation JHEmojiManager

+ (instancetype)manager{
    static JHEmojiManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JHEmojiManager alloc] init];
    });
    return manager;
}

+ (NSDictionary *)jh_all_emoji_with_file:(NSString *)file
{
    if ([[JHEmojiManager manager].file isEqualToString:file] &&
        [JHEmojiManager manager].emojiDic.count > 0) {
        return [JHEmojiManager manager].emojiDic;
    }
    
    // key:face text, value:face image
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:@"plist"]];
    
    [JHEmojiManager manager].file = file;
    [JHEmojiManager manager].emojiDic = dic;
    
    return dic;
}

+ (NSString *)jh_emoji_image_from_text:(NSString *)text
{
    return [[JHEmojiManager manager].emojiDic valueForKey:text];
}

+ (NSAttributedString *)jh_string_contain_emoji:(NSString *)emojiString
{
    if (emojiString.length == 0) {
        return nil;
    }
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:emojiString];
    
    // judge whether there is emoji
    NSString *pattern = @"\\[[NO|OK|\u4e00-\u9fa5]+\\]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *array = [regex matchesInString:emojiString options:0 range:NSMakeRange(0, emojiString.length)];
    
    // no emojis
    if (array.count == 0) {
        return attributeString;
    }
    
    //
    NSMutableArray *replaceArray = @[].mutableCopy;
    for (NSTextCheckingResult *res in array) {
        
        // emoji text
        NSString *subString = [emojiString substringWithRange:res.range];
        
        //
        if ([[[JHEmojiManager manager].emojiDic allKeys] containsObject:subString]) {
            //
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = [UIImage imageNamed:[[JHEmojiManager manager].emojiDic objectForKey:subString]];
            textAttachment.bounds = CGRectMake(0, -5, 20, 20);
            
            //
            NSAttributedString *attString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            
            //
            NSMutableDictionary *replaceDic = @{}.mutableCopy;
            [replaceDic setValue:[NSValue valueWithRange:res.range] forKey:@"range"];
            [replaceDic setValue:attString forKey:@"attString"];
            
            //
            [replaceArray addObject:replaceDic];
        }
    }
    
    for (NSInteger i = replaceArray.count - 1; i >= 0; --i) {
        NSDictionary *dic = replaceArray[i];
        NSRange range;
        [[dic objectForKey:@"range"] getValue:&range];
        [attributeString replaceCharactersInRange:[[dic objectForKey:@"range"] rangeValue]
                                       withAttributedString:[dic objectForKey:@"attString"]];
    }
    
    return attributeString;
}

#pragma mark - getter

- (NSDictionary *)allEmojis{
    return [JHEmojiManager manager].emojiDic;
}

@end
