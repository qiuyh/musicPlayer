//
//  LSFLrcManerger.h
//  musicPlayer
//
//  Created by iMacQIU on 16/1/11.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LSFLrcManerger : NSObject

@property (nonatomic, assign) CGFloat        time ;
@property (nonatomic, copy)   NSString       *lrc;

@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic, strong) NSMutableArray *lrcArray;


- (instancetype)initWithPath:(NSString *)path; // 传入歌词文件的路径;


@end
