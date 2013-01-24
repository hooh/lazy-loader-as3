package me.markezine.lazyloader.core
{
	internal class LazyLoaderDebugger
	{
		static internal function debug(loader:LazyLoader, type:String, item:LazyLoaderItem, additionalInfo:Object=null):void{
			if(!loader && LazyLoader.debugMode.indexOf(type) == -1){
				return;
			}else if(loader && loader.debugMode.indexOf(type) == -1){
				return;
			} 
			
			switch(type){
				case LazyLoaderDebugModes.ADD:
					trace("LazyLoader action: ", type, item.url);
					break;
				
				case LazyLoaderDebugModes.ERRORS:
					trace("LazyLoader action: ", "error", "relative: ", item ? item.url : "no item", "absolute: ", 
						item ? item.absoluteUrl : "no item", "errorType: ", additionalInfo);
					break;
			}
			
		}
	}
}