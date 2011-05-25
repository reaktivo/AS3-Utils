package utils{
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
    import flash.geom.Rectangle;
	import flash.text.*;
	
	import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.display.BlendMode;
    import flash.display.Sprite;

    import flash.geom.Matrix;
    import flash.geom.Point;
	
	import flash.utils.Dictionary;
	
	public class DisplayUtils {
		
		public function DisplayUtils() {
			
		}
		
		public static function sendToFront(... display_objects_arr):void {
			for(var i:int = 0; i< display_objects_arr.length; i++) {
				var d_obj:* = display_objects_arr[i];
				if(d_obj is DisplayObject && d_obj.parent) {
					d_obj.parent.setChildIndex(d_obj, d_obj.parent.numChildren - 1);
				} 
			}
		}
		
		public static function bringToFront(... display_objects_arr):void {
			sendToFront.apply(null, display_objects_arr);
		}
		
		
		public static function sendToBack(... display_objects_arr):void {
			for(var i:int = 0; i< display_objects_arr.length; i++) {
				var d_obj:* = display_objects_arr[i];
				if(d_obj is DisplayObject && d_obj.parent) {
					d_obj.parent.setChildIndex(d_obj, 0);
				} 
			}
		}
		
		public static function sortDepth(container:*, by:Object = "y", startAt:int = 0):void {
			
			var order_by:Array;
			var depth_dict:Dictionary = new Dictionary(true);
			
			
			if(by is Array) {
				order_by = [];
				for each(var b:Object in by) {
					order_by.push(Array.NUMERIC);
				}
			}else{
				by = [by];
				order_by = [Array.NUMERIC];
			}
			
			var objects_arr:Array = new Array();
			
			if(container is DisplayObjectContainer) {
				for(var i:int = 0; i < container.numChildren; i++) {
					objects_arr.push(container.getChildAt(i));
				}
			}else if(container is Array){
				objects_arr = container;
				container = objects_arr[0].parent;
			}else{
				throw new Error("sortDepth function only accepts Array or DisplayObjectContainer objects");
				return;
			}

			objects_arr.sortOn(by, order_by);
			
			if(startAt + objects_arr.length >= container.numChildren) {
				startAt = container.numChildren - objects_arr.length;
			}
			
			var index:int = startAt;
			for each(var display_object:DisplayObject in objects_arr) {
			//	if(depth_dict[display_object] && depth_dict[display_object] != display_object[by]) 
					container.setChildIndex(display_object, index++);
			//	depth_dict[display_object] = display_object[by];
			}
		
		}

		public static function empty( d_obj:* ):void {
			while( d_obj.numChildren > 0 ) {
				d_obj.removeChildAt(0);
			}
		}

		public static function remove(... display_objects_arr):void {
			
			for(var i:int = 0; i< display_objects_arr.length; i++) {
				var d_obj:* = display_objects_arr[i];
				if(d_obj is DisplayObject && d_obj.parent) {
					d_obj.parent.removeChild(d_obj);
				} 
			}
		}
		
		public static function center(obj:DisplayObject, from_center:Boolean = true, stage:* = null):void {
			if ( ! stage ){
				var stage:* = obj.stage;
			}
			if(obj is TextField) {
				(obj as TextField).autoSize = TextFieldAutoSize.CENTER;
			}
			
			obj.x = (stage.stageWidth - (from_center ? 0:obj.width))/2;
			obj.y = (stage.stageHeight - (from_center ? 0:obj.height))/2;
		
			
		}
		
		public static function fitText(tf:TextField, ts:int = 36):void {
				var newFormat:TextFormat = new TextFormat();
				newFormat.size = ts;

				if(tf.multiline) {
					while(tf.textHeight > tf.height) {
						tf.setTextFormat(newFormat);
						newFormat.size = (newFormat.size as int) - 1;
					}
				}else{
					while(tf.textWidth > tf.width) {
						tf.setTextFormat(newFormat);
						newFormat.size = (newFormat.size as int) - 1;
					}
				}
		}
		
		
	    /**
	     * duplicate
	     * creates a duplicate of the DisplayObject passed.
	     * similar to duplicateMovieClip in AVM1
	     * @param target the display object to duplicate
	     * @param autoAdd if true, adds the duplicate to the display list
	     * in which target was located
	     * @return a duplicate instance of target
	     */
	    public static function duplicate(target:DisplayObject, autoAdd:Boolean = false):DisplayObject {
	        // create duplicate
	        var targetClass:Class = Object(target).constructor;
	        var duplicate_do:DisplayObject = new targetClass();

	        // duplicate properties
	        duplicate_do.transform = target.transform;
	        duplicate_do.filters = target.filters;
	        duplicate_do.cacheAsBitmap = target.cacheAsBitmap;
	        duplicate_do.opaqueBackground = target.opaqueBackground;
	        if (target.scale9Grid) {
	            var rect:Rectangle = target.scale9Grid;
	            // WAS Flash 9 bug where returned scale9Grid is 20x larger than assigned
	            // rect.x /= 20, rect.y /= 20, rect.width /= 20, rect.height /= 20;
	            duplicate_do.scale9Grid = rect;
	        }

	        // add to target parent's display list
	        // if autoAdd was provided as true
	        if (autoAdd && target.parent) {
	            target.parent.addChild(duplicate_do);
	        }
	        return duplicate_do;
	    }
		
		
		/** Get the collision rectangle between two display objects. **/
        public static function getCollisionRect(target1:DisplayObject, target2:DisplayObject, commonParent:DisplayObjectContainer, pixelPrecise:Boolean = false, tolerance:Number = 0):Rectangle
        {
            // get bounding boxes in common parent's coordinate space
            var rect1:Rectangle = target1.getBounds(commonParent);
            var rect2:Rectangle = target2.getBounds(commonParent);
           
            // find the intersection of the two bounding boxes
            var intersectionRect:Rectangle = rect1.intersection(rect2);
           
            if (intersectionRect.size.length> 0)
            {
                if (pixelPrecise)
                {
                    // size of rect needs to integer size for bitmap data
                    intersectionRect.width = Math.ceil(intersectionRect.width);
                    intersectionRect.height = Math.ceil(intersectionRect.height);
                   
                    // get the alpha maps for the display objects
                    var alpha1:BitmapData = getAlphaMap(target1, intersectionRect, BitmapDataChannel.RED, commonParent);
                    var alpha2:BitmapData = getAlphaMap(target2, intersectionRect, BitmapDataChannel.GREEN, commonParent);
                   
                    // combine the alpha maps
                    alpha1.draw(alpha2, null, null, BlendMode.LIGHTEN);
                   
                    // calculate the search color
                    var searchColor:uint;
                    if (tolerance <= 0)
                    {
                        searchColor = 0x010100;
                    }
                    else
                    {
                        if (tolerance> 1) tolerance = 1;
                        var byte:int = Math.round(tolerance * 255);
                        searchColor = (byte <<16) | (byte <<8) | 0;
                    }
 
                    // find color
                    var collisionRect:Rectangle = alpha1.getColorBoundsRect(searchColor, searchColor);
                    collisionRect.x += intersectionRect.x;
                    collisionRect.y += intersectionRect.y;
                   
                    return collisionRect;
                }
                else
                {
                    return intersectionRect;
                }
            }
            else
            {
                // no intersection
                return null;
            }
        }
       
        /** Gets the alpha map of the display object and places it in the specified channel. **/
        private static function getAlphaMap(target:DisplayObject, rect:Rectangle, channel:uint, commonParent:DisplayObjectContainer):BitmapData
        {
            // calculate the transform for the display object relative to the common parent
            var parentXformInvert:Matrix = commonParent.transform.concatenatedMatrix.clone();
            parentXformInvert.invert();
            var targetXform:Matrix = target.transform.concatenatedMatrix.clone();
            targetXform.concat(parentXformInvert);
           
            // translate the target into the rect's space
            targetXform.translate(-rect.x, -rect.y);
           
            // draw the target and extract its alpha channel into a color channel
            var bitmapData:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
            bitmapData.draw(target, targetXform);
            var alphaChannel:BitmapData = new BitmapData(rect.width, rect.height, false, 0);
            alphaChannel.copyChannel(bitmapData, bitmapData.rect, new flash.geom.Point(0, 0), BitmapDataChannel.ALPHA, channel);
           
            return alphaChannel;
        }
 
        /** Get the center of the collision's bounding box. **/
        public static function getCollisionPoint(target1:DisplayObject, target2:DisplayObject, commonParent:DisplayObjectContainer, pixelPrecise:Boolean = false, tolerance:Number = 0):flash.geom.Point
        {
            var collisionRect:Rectangle = getCollisionRect(target1, target2, commonParent, pixelPrecise, tolerance);
       
            if (collisionRect != null && collisionRect.size.length> 0)
            {
                var x:Number = (collisionRect.left + collisionRect.right) / 2;
                var y:Number = (collisionRect.top + collisionRect.bottom) / 2;
       
                return new flash.geom.Point(x, y);
            }
       
            return null;
        }
       
        /** Are the two display objects colliding (overlapping)? **/
        public static function isColliding(target1:DisplayObject, target2:DisplayObject, commonParent:DisplayObjectContainer = null, pixelPrecise:Boolean = true, tolerance:Number = 0):Boolean
        {
	
			if(commonParent == null) {
				var t1:DisplayObject = target1;
				var t2:DisplayObject = target2;
				do {
					commonParent = t1.parent;
					t1 = t1.parent;
					t2 = t2.parent;
				}while(t1.parent != t2.parent);
				
			}
			
            var collisionRect:Rectangle = getCollisionRect(target1, target2, commonParent, pixelPrecise, tolerance);
       
            if (collisionRect != null && collisionRect.size.length > 0) return true;
            else return false;
        }
		
		public static function addChildAndOffset($container:DisplayObjectContainer, $d:DisplayObject, $call_super:Boolean = false):DisplayObject {
			var d_offset:Point = $d.localToGlobal(new Point(0, 0));
			
			var offset_point:Point = $container.globalToLocal(d_offset); 
			
			$d.x = offset_point.x;
			$d.y = offset_point.y;
			
			return $container.addChild($d);
			
			
		}

		public static function scaleFromPoint(ob:*, sx:Number, sy:Number, pivot_point:Point):void {
			var m:Matrix=ob.transform.matrix;
			m.translate( -pivot_point.x, -pivot_point.y );
			m.scale( sx, sy );
			m.translate( pivot_point.x, pivot_point.y );
			ob.transform.matrix = m;
		}


	}
}
