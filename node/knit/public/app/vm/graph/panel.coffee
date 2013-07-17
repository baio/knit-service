define ["app/dataProvider", "ural/modules/pubSub"], (dataProvider, pubSub) ->

  class Panel

    constructor: ->
      pubSub.sub "graph", "save", => @save()
      @isForceLayout = true
      @textCls = "text"
      @color = d3.scale.category10().domain(d3.range(10))

    higlightSearch: (val) ->
      @node.style("fill", (d) =>
        if val and d.name.indexOf(val) != -1
          return "red"
        else
          @color(d.group)
      )
      ###
      .attr("r", (d) =>
        if val and d.name.indexOf(val) != -1
          return 7
        else
          5
        )
      ###

    save: ->
      if @id
        upd_data = []
        nodes_data = @node[0].map((d) -> x : d.cx.baseVal.value, y: d.cy.baseVal.value)
        for d, i in nodes_data
          n = @grp_nodes[i]
          if d.x != n.meta.pos[0] or d.y != n.meta.pos[1]
            d.id = n.id
            upd_data.push d
        if upd_data.length != 0
          dataProvider.ajax "graphs", "patch", {graph: @id, data : upd_data}, (err) =>
            if err then toastr.error err, "Ошибка сохранения" else toastr.success "Сохранено успешно"
            if !err
              for d, i in nodes_data
                @grp_nodes[i].meta.pos = [d.x, d.y]
        else
          toastr.warning "Нечего сохранять"

    load: (filter, done) ->

      getEdgeGroup = (edge) ->
        tags = edge.tags
        if tags.filter((t) -> t.type.indexOf("pp-") == 0).length
          return 0
        else if tags.filter((t) -> t.type.indexOf("po-") == 0).length
          return 2
        else if tags.filter((t) -> t.type.indexOf("op-") == 0).length
          return 2
        else if tags.filter((t) -> t.type.indexOf("oo-") == 0).length
          return 1
        else
          return 3

      getNodeGroup = (edges, node) ->
        source_edge = edges.filter((f) -> f.source == node)[0]
        target_edge = edges.filter((f) -> f.target == node)[0]
        if source_edge
          type = source_edge.tags[0].type
          if type.indexOf("pp-") == 0 or type.indexOf("po-") == 0
            return 0
          else if type.indexOf("oo-") == 0 or type.indexOf("op-") == 0
            return 1
        if target_edge
          type = target_edge.tags[0].type
          if type.indexOf("pp-") == 0 or type.indexOf("op-") == 0
            return 0
          else if type.indexOf("po-") == 0 or type.indexOf("oo-") == 0
            return 1
        return 2

      dataProvider.get "graphs", filter, (err, data) =>
        if !err
          @id = data.id
          for edge in data.edges
            edge.target = data.nodes.filter((n) -> n.id == edge.target_id)[0]
            edge.source = data.nodes.filter((n) -> n.id == edge.source_id)[0]
            edge.group = getEdgeGroup edge
          for node in data.nodes
            pos = node.meta.pos
            if pos[0] == -1 then pos[0] = 500
            if pos[1] == -1 then pos[1] = 500
            node.group = getNodeGroup data.edges, node
          @onLoaded data
        done err, data

    render: (data) ->

      width = 2500
      height = 1200

      #scroll to center
      sh = screen.height
      sw = screen.width
      if sh < height
        dy = (height - sh) / 2
        $(document).scrollTop(dy)
      if sw < width
        dx = (width - sw) / 2
        $(document).scrollLeft(dx)

      Mousetrap.bindGlobal ['ctrl+s'], =>
        if @data.isYours
          @save()
        return false

      @force = d3.layout.force()
        .charge(-500)
        .linkDistance(30)
        .linkStrength(0.1)
        .size([width, height])
        .nodes(data.nodes)
        .links(data.edges)
        .on "tick", @_tick

      d3.select("svg")
        .remove();

      svg = d3.select("#graph").append("svg")
        .attr("width", width)
        .attr("height", height)
        .on("click", @onClickSvg)
        .on("dblclick", @onDblClickSvg)

      @nodes = @force.nodes()
      @links = @force.links()
      @node = svg.selectAll("node")
      @link = svg.selectAll("link")
      @text = svg.selectAll("text")

      @_restart()

    _restart: ->

      color = @color

      @link = @link.data(@links)

      @link.enter()
        .append("line")
        .attr("class", "link")
        .style("stroke", (d) ->
          color(d.group)
        )
        .attr("x1", (d) -> d.source.meta.pos[0])
        .attr("y1", (d) -> d.source.meta.pos[1])
        .attr("x2", (d) -> d.target.meta.pos[0])
        .attr("y2", (d) -> d.target.meta.pos[1])
        .on("mouseover", @onHoverEdge)
        .on("click", @onClickEdge)

      @text = @text.data(@nodes)

      @text.enter()
        .append("text")
        .attr("class", @textCls)
        .attr("text-anchor", "middle")
        .text((d) -> d.name)
        .attr("x", (d) -> d.meta.pos[0])
        .attr("y", (d) -> d.meta.pos[1] - 10)

      @node = @node.data(@nodes)

      @node
        .enter()
        .append("circle")
        .attr("r", 5)
        .attr("cx", (d) -> d.meta.pos[0])
        .attr("cy", (d) -> d.meta.pos[1])
        .attr("class", "link")
        .style("fill", (d) -> color(d.group))
        .on("click", @onClickNode)
        #.call(@force.drag)

      #@force.start()
      @setForceLayout(@isForceLayout)

    _tick: =>
      @link
        .attr("x1", (d) => @_getX d.source.x)
        .attr("y1", (d) => @_getY d.source.y)
        .attr("x2", (d) => @_getX d.target.x)
        .attr("y2", (d) => @_getY d.target.y)
      @node
        .attr("cx", (d) => @_getX d.x)
        .attr("cy", (d) => @_getY d.y)
      @text
        .attr("x", (d) => @_getX d.x)
        .attr("y", (d) => @_getY(d.y) - 10)


    _getX: (x) ->
      width = 2500
      r = 20
      return Math.max(r, Math.min(width - r, x))

    _getY: (y) ->
      height = 1200
      r = 20
      return Math.max(r, Math.min(height - r, y))


    onHoverEdge: (edge) ->
    onClickEdge: (edge) ->
    onClickSvg: ->
    onDblClickSvg: ->

    onClickNode: (node) =>
      console.log "onclick node"
      @load src: node.id, (err, data) =>
        if !err
          @data = data
          new_nodes = data.nodes.filter((f) => !@nodes.filter((g) -> f.id == g.id)[0])
          new_edges = data.edges.filter((f) => !@links.filter((g) -> f.id == g.id)[0])
          if new_nodes.length or new_edges.length
            for n in new_nodes
              @nodes.push n
            for e in new_edges
              t = @nodes.filter((f) -> f.id == e.target.id)[0]
              if t then e.target = t
              s = @nodes.filter((f) -> f.id == e.source.id)[0]
              if s then e.source = s
              @links.push e
            @_restart()

    onLoaded: (data) ->

    toData: ->
      @data.nodes

    updateText: (@textCls) ->
      @text.attr("class", textCls)

    setForceLayout: (@isForceLayout) ->
      if isForceLayout
        @node.call(@force.drag)
        @force.start()
      else
        @node.call(@_getDrag())
        @force.stop()

    _getDrag: ->
      _this = @
      d3.behavior.drag()
        .origin((d) -> d)
        .on("drag", (d) ->
          x = parseFloat(d3.select(@).attr("cx")) + d3.event.dx
          y = parseFloat(d3.select(@).attr("cy")) + d3.event.dy
          d3.select(@).attr("cx", x).attr("cy", y)
          _this.link.filter((l) -> l.source == d).attr("x1", x).attr("y1", y)
          _this.link.filter((l) -> l.target == d).attr("x2", x).attr("y2", y)
          _this.text.filter((t) -> t.id == d.id).attr("x", x).attr("y", y - 10)
        )


    resetPositions: ->

      @node.attr("cx", (d) -> d.meta.pos[0])
      @node.attr("cy", (d) -> d.meta.pos[1])
      @link.attr("x1", (d) -> d.source.meta.pos[0])
      @link.attr("y1", (d) -> d.source.meta.pos[1])
      @link.attr("x2", (d) -> d.target.meta.pos[0])
      @link.attr("y2", (d) -> d.target.meta.pos[1])
      @text.attr("x", (d) -> d.meta.pos[0])
      @text.attr("y", (d) -> d.meta.pos[1] - 10)

