//
//  Map.h
//  ProceduralLevelGeneration
//
//  Created by Scott Gardner on 3/7/14.
//  Copyright (c) 2014 Kim Pedersen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Map : SKNode

@property (assign, nonatomic) CGSize gridSize;
@property (assign, nonatomic, readonly) CGPoint spawnPoint;
@property (assign, nonatomic, readonly) CGPoint exitPoint;
@property (assign, nonatomic) NSUInteger maxFloorCount;

+ (instancetype)mapWithGridSize:(CGSize)gridSize;
- (instancetype)initWithGridSize:(CGSize)gridSize;
- (void)generate;

@end
