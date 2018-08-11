@interface SBUILegibilityLabel : UIView
@property (nonatomic,copy) NSString *string;
@end

@interface NCNotificationListSectionRevealHintView : UIView
@property (nonatomic,retain) SBUILegibilityLabel * revealHintTitle;
@property (nonatomic,retain) NSTimer *urbanTimer;
- (void)_updateHintTitle;
- (NSString *)updateUrbanWord;
@end

%hook NCNotificationListSectionRevealHintView

%property (nonatomic,retain) NSTimer *urbanTimer;

- (instancetype)initWithFrame:(CGRect)arg1 {
	%orig;

	// Get the date for midnight
	NSDate *const date = NSDate.date;
	NSCalendar *const calendar = NSCalendar.currentCalendar;
	NSCalendarUnit const preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
	NSDateComponents *const components = [calendar components:preservedComponents fromDate:date];
	NSDate *const dateToFire = [calendar dateFromComponents:components];

	// Create a timer that fires every 24 hours, starting at midnight
	NSTimer *timer = [[NSTimer alloc] initWithFireDate:dateToFire
                        						interval:86400
                         						repeats:YES
                           					block:^(NSTimer *timer) { [self _updateHintTitle]; }];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

	// Add it as a property of the NCNotificationListSectionRevealHintView class
	self.urbanTimer = timer;

	return self;
}

- (void)_updateHintTitle {
	%orig;
	self.revealHintTitle.string = [self updateUrbanWord];
}

%new - (NSString *)updateUrbanWord {
	NSURL *url = [NSURL URLWithString:[@"http://urban-word-of-the-day.herokuapp.com/today" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

	NSData *data = [NSData dataWithContentsOfURL:url];
	NSError *error = nil;
	NSDictionary *urbanDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

	NSString *word = [[[urbanDictionary objectForKey:@"word"] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
	NSString *meaning = [[[urbanDictionary objectForKey:@"meaning"] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
	NSString *example = [[[urbanDictionary objectForKey:@"example"] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];

	return [NSString stringWithFormat:@"%@\n%@\n%@", word, meaning, example];
}

%end
