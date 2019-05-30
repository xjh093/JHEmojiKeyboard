//
//  JHEmojiPadView.h
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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JHEmojiType) {
    JHEmojiType_Face1,  //the first set emoji
    JHEmojiType_Face2,  //the second set emoji
};

typedef void (^JHEmojiClickBlock)(NSString *face,NSString *text);
typedef void (^JHEmojiDeleteBlock)(void);

@class JHEmojiPadConfig;

@interface JHEmojiPadView : UIView

@property (nonatomic,    copy) JHEmojiClickBlock emojiClickBlock;
@property (nonatomic,    copy) JHEmojiDeleteBlock emojiDeleteBlock;

- (instancetype)initWithFrame:(CGRect)frame config:(JHEmojiPadConfig *)config;

@end

@interface JHEmojiPadConfig : NSObject

/// there are two sets emoji for you to choose.
@property (nonatomic,  assign) JHEmojiType  emojiType;
/// rows in one page.
@property (nonatomic, assign) NSInteger row;
/// columns in one page.
@property (nonatomic, assign) NSInteger column;
/// space of rows.
@property (nonatomic, assign) CGFloat rowSpacing;
/// space of column.
@property (nonatomic, assign) CGFloat columnSpacing;
/// size of item.
@property (nonatomic, assign) CGSize size;
/// width of one page.
@property (nonatomic, assign) CGFloat pageWidth;
/// top offset.
@property (nonatomic,  assign) CGFloat  topOffset;
@end
