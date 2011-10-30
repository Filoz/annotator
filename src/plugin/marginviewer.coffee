class Annotator.Plugin.MarginViewer extends Annotator.Plugin
  events:
    'annotationsLoaded': 'onAnnotationsLoaded'      
    'annotationCreated': 'onAnnotationCreated'      
    'annotationDeleted': 'onAnnotationDeleted'      
    'annotationUpdated': 'onAnnotationUpdated'      
            
  pluginInit: ->
    return unless Annotator.supported()
    @annotator.viewer =
      on: ->
      hide: -> 
      load: ->
      isShown: ->
      element:
        css: ->
        position: ->
    
  onAnnotationsLoaded: (annotations) ->
   this.onAnnotationCreated(a) for a in annotations

  onAnnotationCreated: (annotation) ->
    $('<div class="annotation-text">'+annotation.text+'</div>').appendTo('.secondary').css({position: 'absolute', top: annotation.highlights[0].offsetTop+53+'px'})
    
  onAnnotationDeleted: (annotation) ->
    # do other stuff
    
  onAnnotationUpdated: (annotation) ->
    # yet more stuff
