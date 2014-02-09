//
//  Cropping Video Square Like Vine
//  Created by onedreamer pty ltd Feb/07/14
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>


@class AVPlayerDemoPlaybackView;
@class AVPlayer;
@interface ViewController : UIViewController{

    IBOutlet AVPlayerDemoPlaybackView  *mPlaybackView;
    AVAssetExportSession *exporter;
}


@property (readwrite, retain) AVPlayer* mPlayer;
@property (nonatomic, retain) IBOutlet AVPlayerDemoPlaybackView *mPlaybackView;


- (void)exportDidFinish:(AVAssetExportSession*)session;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
@end

