//
//  JHEmojiPadView.m
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

#import "JHEmojiPadView.h"
#import "JHEmojiPadCell.h"
#import "JHEmojiManager.h"
#import "JHCollectionViewFlowLayout.h"

#define JHEmojiPadView_UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface JHEmojiPadView()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>
@property (nonatomic,  strong) UICollectionView *collectionView;
@property (nonatomic,  strong) NSMutableArray *dataArray;
@property (nonatomic,  strong) JHEmojiPadConfig *config;
@property (nonatomic,  strong) UIPageControl *pageControl;
@end

@implementation JHEmojiPadView

- (instancetype)init{
    if (self = [super init]) {
        _config = [[JHEmojiPadConfig alloc] init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (!_config) {
        _config = [[JHEmojiPadConfig alloc] init];
    }
    frame.size.width  = CGRectGetWidth(self.collectionView.frame);
    frame.size.height = CGRectGetMaxY(self.pageControl.frame);
    self = [super initWithFrame:frame];
    if (self) {
        // automaticallyAdjustsScrollViewInsets is deprecated in iOS 11
        // add a view before collectionView in superview
        // so we don't care the property any more
        // 2017-12-25 18:48:51
        [self addSubview:[[UIView alloc] init]];
        [self addSubview:_collectionView];
        [self addSubview:_pageControl];
        [self xx_init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame config:(JHEmojiPadConfig *)config
{
    if (config) {
        _config = config;
    }else{
        _config = [[JHEmojiPadConfig alloc] init];
    }
    frame.size.width  = CGRectGetWidth(self.collectionView.frame);
    frame.size.height = CGRectGetMaxY(self.pageControl.frame);
    self = [super initWithFrame:frame];
    if (self) {
        // automaticallyAdjustsScrollViewInsets is deprecated in iOS 11
        // add a view before collectionView in superview
        // so we don't care the property any more
        // 2017-12-25 18:48:51
        
        [self addSubview:[[UIView alloc] init]];
        [self addSubview:_collectionView];
        [self addSubview:_pageControl];
        [self xx_init];
    }
    return self;
}

- (void)xx_init
{
    self.backgroundColor = JHEmojiPadView_UIColorFromRGB(0xf5f7f9);
    
    // iPhoneX
    if (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame])==44) {
        CGRect frame = self.frame;
        frame.size.height += 34;
        self.frame = frame;
    }
}

- (void)layoutSubviews{
    [self xx_layout_pageControl];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self xx_layout_pageControl];
    });
}

- (void)xx_layout_pageControl
{
    // NSLog(@"%s",__func__);
    // add button on pageControl to cover every dot.
    // so you can click one dot and select it, not one by one.
    NSInteger count = _pageControl.numberOfPages;
    for (int i = 0; i < count; ++i) {
        
        UIView *view = _pageControl.subviews[i];
        
        CGRect frame = view.frame;
        frame.origin.y = 0;
        frame.origin.x -= 3.5;
        frame.size.width += 7;
        frame.size.height = CGRectGetHeight(_pageControl.frame);
        
        UIButton *button = [_pageControl viewWithTag:100 + i];
        if (!button) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag =  100 + i;
            // button.backgroundColor = [UIColor lightGrayColor];
            [button addTarget:self action:@selector(xx_click_button:) forControlEvents:1<<6];
            [_pageControl addSubview:button];
            // NSLog(@"crate i:%@, frame:%@",@(i),NSStringFromCGRect(frame));
        }else{
            button.frame = frame;
            // NSLog(@"set i:%@, frame:%@",@(i),NSStringFromCGRect(button.frame));
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JHEmojiPadCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JHEmojiPadCell_ID" forIndexPath:indexPath];
    cell.image = [UIImage imageNamed:[_dataArray[indexPath.row] allValues][0]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = _dataArray[indexPath.row];
    if (_emojiClickBlock) {
        _emojiClickBlock(dic.allValues[0],dic.allKeys[0]);
    }
    //NSLog(@"点击了表情:%@",dic.allValues[0]);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x / _config.pageWidth;
    _pageControl.currentPage = page;
}

#pragma mark - control event

- (void)xx_click_pageContrl:(UIPageControl *)pageControl
{
    //NSLog(@"%s,%@",__func__,@(pageControl.currentPage));
    [self xx_scroll_collectionView];
}

- (void)xx_click_button:(UIButton *)button
{
    //NSLog(@"%s,%@",__func__,@(button.tag));
    _pageControl.currentPage = button.tag - 100;
    [self xx_scroll_collectionView];
}

- (void)xx_scroll_collectionView
{
    NSInteger currentPage = _pageControl.currentPage;
    _collectionView.contentOffset = CGPointMake(currentPage*_config.pageWidth, 0);
}

#pragma mark - lazy load

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        NSInteger row    = _config.row;
        NSInteger column = _config.column;
        CGFloat   width  = _config.pageWidth;
        CGSize    size   = _config.size;
        
        JHCollectionViewFlowLayout *flowLayout = [[JHCollectionViewFlowLayout alloc] init];
        flowLayout.row = row;
        flowLayout.column = column;
        flowLayout.pageWidth = width;
        flowLayout.size = size;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _config.topOffset >= 0 ? _config.topOffset : 0, flowLayout.pageWidth, flowLayout.row*flowLayout.size.height) collectionViewLayout:flowLayout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.pagingEnabled = YES;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[JHEmojiPadCell class] forCellWithReuseIdentifier:@"JHEmojiPadCell_ID"];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
        
        // name of plist
        NSString *file = _config.emojiType == JHEmojiType_Face1 ? @"face1" : @"face2";
        NSString *delete_image = _config.emojiType == JHEmojiType_Face1 ? @"face1_delete" : @"emoji_delete";
        
        // key:text, value:image
        NSDictionary *dic = [JHEmojiManager jh_all_emoji_with_file:file];
        
        // sort face1_000,face1_001,face1_002,face1_003.....
        NSArray *allValues = [dic.allValues sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        // sort by value's order
        NSArray *allKeys = [dic keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        // @{text:image}
        for (int i = 0; i < allValues.count; ++i) {
            NSString *value = allValues[i]; // image
            NSString *key   = allKeys[i];   // text
            NSDictionary *tdic = @{key:value};
            [_dataArray addObject:tdic];
            
            // the last one in one page,use the "delete" image
            if ((_dataArray.count + 1) % (_config.row * _config.column) == 0 ||
                i == allKeys.count - 1) {
                [_dataArray addObject:@{@"[删除]":delete_image}];
            }
        }
    }
    return _dataArray;
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.frame = CGRectMake(0, CGRectGetMaxY(_collectionView.frame), CGRectGetWidth(_collectionView.frame), 30);
        pageControl.numberOfPages = (ceil)(self.dataArray.count/(double)(_config.row * _config.column));
        pageControl.pageIndicatorTintColor = JHEmojiPadView_UIColorFromRGB(0xcccccc);
        pageControl.currentPageIndicatorTintColor = JHEmojiPadView_UIColorFromRGB(0x00C9FB);
        [pageControl addTarget:self action:@selector(xx_click_pageContrl:) forControlEvents:UIControlEventValueChanged];
        _pageControl = pageControl;
    }
    return _pageControl;
}

@end

@implementation JHEmojiPadConfig

- (instancetype)init{
    if (self = [super init]) {
        _row = 3;
        _column = 7;
        _pageWidth = [UIScreen mainScreen].bounds.size.width;
        _size = CGSizeMake(_pageWidth/_column, _pageWidth/_column);
        
        _emojiType = JHEmojiType_Face2;
    }
    return self;
}

@end
