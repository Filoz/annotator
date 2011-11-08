class Annotator.Plugin.MarginViewer extends Annotator.Plugin
  events:
    'annotationsLoaded': 'onAnnotationsLoaded'      
    'annotationCreated': 'onAnnotationCreated'      
    'annotationDeleted': 'onAnnotationDeleted'      
    'annotationUpdated': 'onAnnotationUpdated'      
            
  pluginInit: ->
    return unless Annotator.supported()
    @marginObjects = [] 
    @objectIndex = {}
    @annotator.viewer =
      on: ->
      hide: -> 
      load: ->
      isShown: ->
      element:
        css: ->
        position: ->
    
  onAnnotationsLoaded: (annotations) ->
    RTL_MULT = -1 #should be -1 if RTL else 1
    sign = (x) ->
      if(x==0)
        return 0
      else
        return x/Math.abs(x)
    getPos = (annotation) ->
      return {top:annotation.highlights[0].offsetTop,left:annotation.highlights[0].offsetLeft}
    sortfunc = (left,right) -> 
      leftpos = getPos(left)
      rightpos = getPos(right)
      return sign(sign(leftpos.top - rightpos.top)*2 + sign(leftpos.left - rightpos.left)*RTL_MULT)
    annotations.sort(sortfunc)
    @marginIndex = annotations.map((x) -> return [x.highlights[0].offsetTop,x.highlights[0].offsetLeft,x])
    for index in [0..@marginIndex.length-1]
      obj = @marginIndex[index][3]
      @objectIndex[obj.id]=index
    this.onAnnotationCreated(a) for a in annotations

  onAnnotationCreated: (annotation) ->
    #@marginIndex[annotation.id]=annotation
    console.log("Added annotation " + annotation.text)
    $('<div class="annotation-text">'+annotation.text+'</div>').appendTo('.secondary').css({position: 'absolute', top: annotation.highlights[0].offsetTop+53+'px'})
    
  onAnnotationDeleted: (annotation) ->
    # do other stuff
    
  onAnnotationUpdated: (annotation) ->
    # yet more stuff
