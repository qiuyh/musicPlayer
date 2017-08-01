//
//  LSFLrcManerger.m
//  musicPlayer
//
//  Created by iMacQIU on 16/1/11.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "LSFLrcManerger.h"

@implementation LSFLrcManerger

- (instancetype)initWithPath:(NSString *)path
{
    if (self = [super init])
    {
        _lrcArray  = [[NSMutableArray alloc] init]; // 实例化可变数组, 后续用来存储歌词对象;
        _timeArray = [[NSMutableArray alloc] init];
    }
    // 歌词解析:
    [self paserPath:path];
    
    return self;
}
// 解析歌词
- (void)paserPath:(NSString *)path
{
    //  读取文件内容
    NSString *conStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    // 以\n分割:
    NSArray *allArray = [conStr componentsSeparatedByString:@"\n"];
    //arr[0]第一行内容，   arr[1]第二行内容  。。。。。。。
    for (NSString *str in allArray)
    {
        
        if ([str isEqualToString:@""])
        {
            continue;
        }
        if ([str hasPrefix:@"["])
        {
            // 歌词:
            [self paserWithItem:str];
            
        }
    }
}
//获取歌词信息;
- (void)paserWithItem:(NSString *)item
{
    // 以] 分割:
    NSArray *arr = [item componentsSeparatedByString:@"]"];
    //    [04:40.75][02:39.90][00:36.25]只是因为在人群中多看了你一眼
    //arr[0]: [04:40.75
    //arr[1]: [02:39.90
    //arr[2]: [00:36.25
    //arr[3]: 歌词
    for (NSString *s in arr)
    {
        if ([s hasPrefix:@"["]) {
            // 时间:
            _time = [self timeFromString:s];
            _lrc = [arr lastObject]; // 时间对应的歌词内容;
            [_lrcArray  addObject:_lrc];   // 把歌词添加到数组里面;
            [_timeArray addObject:[NSString stringWithFormat:@"%f",_time]];
        }
    }
   
}

// 解析时间
- (CGFloat)timeFromString:(NSString *)string
{
    //[04:40.75
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"[:"];
    NSArray *arr = [string componentsSeparatedByCharactersInSet:charSet];
    // arr[0]:  @"";
    // arr[1]:  04;
    // arr[2]:  40.75
    return [arr[1] floatValue] * 60 + [arr[2] floatValue];
}



@end
