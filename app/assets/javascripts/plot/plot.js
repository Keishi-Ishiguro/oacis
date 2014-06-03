function Plot() {
  this.row = d3.select("#plot").insert("div","div").attr("class", "row");
  this.plot_region = this.row.append("div").attr("class", "span8");
  this.description = this.row.append("div").attr("class", "span4");
  this.svg = this.plot_region.insert("svg")
    .attr({
      "width": this.width + this.margin.left + this.margin.right,
      "height": this.height + this.margin.top + this.margin.bottom
    })
    .append("g")
      .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")");
}

Plot.prototype.margin = {top: 10, right: 100, bottom: 100, left: 100};
Plot.prototype.width = 560;
Plot.prototype.height = 460;
Plot.prototype.xScale = null;
Plot.prototype.yScale = null;
Plot.prototype.xAxis = null;
Plot.prototype.yAxis = null;
Plot.prototype.data = null;
Plot.prototype.url = null;
Plot.prototype.current_ps_id = null;
Plot.prototype.parameter_set_base_url = null;

Plot.prototype.Init = function(data, url, parameter_set_base_url, current_ps_id) {
  this.data = data;
  this.url = url;
  this.parameter_set_base_url = parameter_set_base_url;
  this.current_ps_id = current_ps_id;

  this.SetXScale("linear");
  this.SetYScale("linear");
  this.xAxis = d3.svg.axis().scale(this.xScale).orient("bottom");
  this.yAxis = d3.svg.axis().scale(this.yScale).orient("left");
};

Plot.prototype.Destructor = function() { this.row.remove(); };

Plot.prototype.AddAxis = function() {
  // X-Axis
  this.svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + this.height + ")")
    .append("text")
      .style("text-anchor", "middle")
      .attr("x", this.width / 2.0)
      .attr("y", 50.0)
      .text(this.data.xlabel);

  // Y-Axis
  this.svg.append("g")
    .attr("class", "y axis")
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("x", -this.height/2)
      .attr("y", -50.0)
      .style("text-anchor", "middle")
      .text(this.data.ylabel);

  this.UpdateAxis();
};

Plot.prototype.UpdateAxis = function() {
  this.svg.select(".x.axis").call(this.xAxis);
  this.svg.select(".y.axis").call(this.yAxis);
}

