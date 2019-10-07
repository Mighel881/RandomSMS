#include <stdlib.h>
#include <substrate.h>

@interface TLAlertConfiguration : NSObject
-(long long)type;
-(NSString *)audioCategory;
-(NSString *)topic;
-(NSString *)toneIdentifier;
-(BOOL)shouldIgnoreRingerSwitch;
-(NSURL *)externalToneFileURL;
-(void)setExternalToneFileURL:(NSURL *)arg1 ;
-(id)initWithType:(long long)arg1 ;
@end
@interface TLAlert : NSObject
-(NSString *)toneIdentifier;
-(TLAlertConfiguration *)configuration;
-(id)_initWithConfiguration:(id)arg1 toneIdentifier:(id)arg2 vibrationIdentifier:(id)arg3 ;

@end

@interface TLAlertSystemSoundController
-(NSURL *)randomURL;
@end

%hook TLAlertSystemSoundController
-(void)playAlert:(id)arg1 withCompletionHandler:(/*^block*/id)arg2 
{
	if ([[arg1 toneIdentifier] containsString:@"texttone"])
	{
		TLAlertConfiguration *newConfig = [[%c(TLAlertConfiguration) alloc] initWithType:0];
		[newConfig setExternalToneFileURL:[self randomURL]];
		TLAlert *newAlert = [[%c(TLAlert) alloc] _initWithConfiguration:newConfig toneIdentifier:nil vibrationIdentifier:nil];
		%orig(newAlert, arg2);
	}
	else
	{
		%orig;
	}
}
%new
-(NSURL *)randomURL
{
	NSString *tonesPath = @"/var/mobile/Media/iTunes_Control/Ringtones/";
	NSArray* allFilesAtTonesPath = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tonesPath error:NULL];
	NSMutableArray *m4rFiles = [[NSMutableArray alloc] init];
	[allFilesAtTonesPath enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSString *filename = (NSString *)obj;
		NSString *extension = [[filename pathExtension] lowercaseString];
		if ([extension isEqualToString:@"m4r"]) {
			[m4rFiles addObject:[tonesPath stringByAppendingPathComponent:filename]];
		}
	}];
	NSLog(@"%@", m4rFiles);
	int randomIndex = arc4random_uniform([m4rFiles count]);
	return [NSURL URLWithString: [m4rFiles objectAtIndex:randomIndex]];
}
%end