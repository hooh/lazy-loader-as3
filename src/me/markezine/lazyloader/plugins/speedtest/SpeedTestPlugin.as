package me.markezine.lazyloader.plugins.speedtest
{
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import me.markezine.lazyloader.core.LazyLoader;
	import me.markezine.lazyloader.events.LazyLoaderEvent;
	import me.markezine.lazyloader.interfaces.ILazyLoaderPlugin;

	public class SpeedTestPlugin implements ILazyLoaderPlugin
	{
		private var instance:LazyLoader;
		private var _lastTime:int = 0;
		private var _lastBytesLoaded:int = 0;
		private var _currentbpms:uint = 0;
		private var bpmsData:Vector.<Number> = new Vector.<Number>();
		
		public function init(instance:LazyLoader):void{		
			instance.addEventListener(LazyLoaderEvent.PROGRESS, progressListener);
			instance.addEventListener(LazyLoaderEvent.COMPLETE, completeListener);
			this.instance = instance;
		}
		
		protected function completeListener(event:Event):void
		{
			instance.removeEventListener(LazyLoaderEvent.PROGRESS, progressListener);
			instance.removeEventListener(LazyLoaderEvent.COMPLETE, completeListener);
		}
		
		protected function progressListener(event:LazyLoaderEvent):void
		{
			var time:int = getTimer();
			var bytesLoaded:uint = event.bytesLoaded;
			
			if(_lastTime > 0){
				var bpms:Number = (bytesLoaded - _lastBytesLoaded)/(time - _lastTime);
				_currentbpms = bpms;
				bpmsData.push(_currentbpms);
			}
			
			_lastBytesLoaded = bytesLoaded;
			_lastTime = time;
		}
		
		public function get currentMBPS():Number{
			return currentKBPS/1024;
		}
		
		public function get currentKBPS():Number{
			return _currentbpms/1.024;
		}
		
		public function get currentBPS():Number{
			return _currentbpms*1000;
		}
		
		public function get currentBPMS():Number{
			return _currentbpms;
		}
		
		public function calculateAverageMBPS():Number{
			return calculateAverageKBPS()/1024;
		}
		
		public function calculateAverageKBPS():Number{
			return calculateAverageBPMS()/1.024;
		}
		
		public function calculateAverageBPS():Number{
			return calculateAverageBPMS()*1000;
		}
		
		public function calculateAverageBPMS():Number{
			var total:Number = 0;
			for(var i:String in bpmsData){
				total += bpmsData[i];
			}
			return total/bpmsData.length;
		}
	}
}