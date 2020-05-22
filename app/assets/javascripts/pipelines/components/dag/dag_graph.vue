<script>
import * as d3 from 'd3';
import { uniqueId } from 'lodash';

import {
  createSankey,
  getMaxNodes,
  removeOrphanNodes,
} from './utils'

export default {
  viewOptions: {
    baseHeight: 300,
    baseWidth: 1000,
    minNodeHeight: 60,
    nodeWidth: 15,
    nodePadding: 25,
    paddingForLabels: 100,
    labelMargin: 8,

    // can plausibly applied through CSS instead, TBD
    baseOpacity: 0.8,
    highlightIn: 1,
    highlightOut: 0.2,

    containerClasses: [
      'dag-graph-container',
      'gl-relative',
      'gl-display-flex',
      'gl-justify-content-start',
      'gl-flex-direction-column',
    ].join(' ')
  },
  gitLabColorRotation: [
    '#e17223',
    '#83ab4a',
    '#5772ff',
    '#b24800',
    '#25d2d2',
    '#006887',
    '#487900',
    '#d84280',
    '#3547de',
    '#6f3500',
    '#006887',
    '#275600',
    '#b31756',
  ],
  props: {
    graphData: {
      type: Object,
      required: true,
    }
  },
  data: function() {
    return {
      color: () => {},
      width: 0,
      height: 0,
    }
  },
  mounted() {
    this.drawGraph(this.graphData);
  },
  methods: {
    addSvg() {
       return d3
        .select('.dag-graph-container')
        .append('svg')
        .attr('viewBox', [0, 0, this.width, this.height])
        .attr('width', this.width)
        .attr('height', this.height);
    },

    appendLinks(link) {

        const createLinkPath = (d, i) => {
          const { nodeWidth } = this.$options.viewOptions;

          const xValRaw = (d.source.x1 + ((i + 1) * d.width) % ((d.target.x1 - d.source.x0)));
          const xValMin = Math.max((xValRaw + nodeWidth), d.width);
          const overlapPoint = d.source.x1 + (d.target.x0 - d.source.x1);
          /**
            Math.random adds a little blur, so the  don't sit right on one another
            Increasing the value it is multipled by will increase the blur
          **/
          const midPointX = Math.min(
            xValMin,
            (d.target.x0 - ((4 * nodeWidth * Math.random()))),
            overlapPoint - (nodeWidth * 1.4)
          )

          return d3.line()([
            [(d.source.x0 + d.source.x1) / 2, d.y0],
            [midPointX, d.y0],
            [midPointX, d.y1],
            [(d.target.x0 + d.target.x1) / 2, d.y1],
          ]);
        };

        link
          .append('path')
          .attr('d', createLinkPath)
          .attr('stroke', (d) => `url(#${d.gradId})`)
          .style('stroke-linejoin', 'round')
          // minus two to account for the rounded nodes
          .attr('stroke-width', (d) => Math.max(1, d.width - 2))
          .attr('clip-path', (d) => `url(#${d.clipId})`);
    },

    appendLabelAsForeignObject (d, i, n) {
      const currentNode = n[i];
      const {
        height,
        wrapperWidth,
        width,
        x,
        y,
        textAlign,
      } = this.labelPosition(d);

      const labelClasses = [
        'dag-label',
        'gl-display-flex',
        'gl-pointer-events-none',
        'gl-flex-direction-column',
        'gl-justify-content-center',
        'gl-overflow-wrap-break',
      ]

      return d3.select(currentNode)
        .attr('requiredFeatures', 'http://www.w3.org/TR/SVG11/feature#Extensibility')
        .attr('height', height)
        .attr('width', wrapperWidth || width)
        .attr('x', x)
        .attr('y', y)
        .style('overflow', 'visible')
        .append('xhtml:div')
        .classed(labelClasses.join(' '), true)
        .style('height', height)
        .style('width', width)
        .style('text-align', textAlign)
        .text((d) => d.name);
    },

    createClip(link) {
      /*
        Because large link values can overrun their box, we create a clip path
        to trim off the excess in charts that have few nodes per column and are
        therefore tall.
      */
      const clip = (d) => `
        M${d.source.x0}, ${d.y1}
        V${Math.max(Math.max(d.y1, d.y0) + (d.width / 2), d.y0, d.y1)}
        H${d.target.x1}
        V${Math.min(Math.min(d.y0, d.y1) - (d.width / 2), d.y0, d.y1)}
        H${d.source.x0}
        Z`

      link
        .append('clipPath')
        .attr('id', (d) => (d.clipId = uniqueId('clip')))
        .append('path')
        .attr('d', clip)
    },

    createGradient(link) {
      const gradient = link
        .append('linearGradient')
        .attr('id', (d) => (d.gradId = uniqueId('grad')))
        .attr('gradientUnits', 'userSpaceOnUse')
        .attr('x1', (d) => d.source.x1)
        .attr('x2', (d) => d.target.x0);

      gradient
        .append('stop')
        .attr('offset', '0%')
        .attr('stop-color', (d) => this.color(d.source));

      gradient
        .append('stop')
        .attr('offset', '100%')
        .attr('stop-color', (d) => this.color(d.target));
    },

    createLinks (svg, linksData) {
      const link = this.generateLinks(svg, linksData);
      this.createGradient(link);
      this.createClip(link);
      this.appendLinks(link);
    },

    createNodes (svg, nodeData) {
      this.generateNodes(svg, nodeData);
      this.labelNodes(svg, nodeData);
    },

    drawGraph(initialData) {
      const {
        baseWidth,
        baseHeight,
        minNodeHeight,
        nodeWidth,
        nodePadding,
        paddingForLabels,
      } = this.$options.viewOptions;

      const { maxNodesPerLayer, linksAndNodes } = this.transformData(initialData);

      this.width = baseWidth;
      this.height= baseHeight + (maxNodesPerLayer * minNodeHeight);
      this.color = this.initColors();

      const sankey = createSankey({
        width: this.width,
        height: this.height,
        nodeWidth,
        nodePadding,
        paddingForLabels,
      })(linksAndNodes);

      const svg = this.addSvg();
      this.createLinks(svg, sankey.links);
      this.createNodes(svg, sankey.nodes);

    },

    generateJunctionPath (d) {
      const width = d.x1 - d.x0;
      const halfWidth = width / 2;
      return `
          M ${d.x0 + width} ${d.y0 + halfWidth}
          a ${halfWidth} ${halfWidth} 0 0 0 -${width} 0
          v ${d.y1 - d.y0 - width}
          a ${halfWidth} ${halfWidth} 0 0 0 ${width} 0
          z
          `;
    },

    generateLinks (svg, linksData) {
      return svg
        .append('g')
        .attr('fill', 'none')
        .attr('stroke-opacity', this.$options.viewOptions.baseOpacity)
        .selectAll('.link')
        .data(linksData)
        .enter()
        .append('g')
        .attr('id', (d) => d.uid = uniqueId('link'))
        .classed('link gl-cursor-pointer', true)
    },

    generateNodes (svg, nodeData) {
      const {
        colorNodes,
        strokeNodes,
      } = this.$options.viewOptions;

      return svg
        .append('g')
        .attr('stroke', '#000')
        .selectAll('.junction-points')
        .data(nodeData)
        .enter()
        .append('path')
        .classed('junction-points gl-cursor-pointer', true)
        .attr('id', (d) => d.uid = uniqueId('node'))
        .attr('d', (d) => this.generateJunctionPath(d))
        .attr('stroke', this.color)
        .attr('stroke-width', '2')
        .attr('fill', this.color)
        .append('title')
        .text((d) => d.name);
    },

    labelNodes (svg, nodeData) {
      return svg
        .append('g')
        .attr('font-family', 'sans-serif')
        .attr('font-size', 12)
        .selectAll('text')
        .data(nodeData)
        .enter()
        .append('foreignObject')
        .each(this.appendLabelAsForeignObject);

    },

    initColors (colorProp) {
      const colorFn = d3.scaleOrdinal(this.$options.gitLabColorRotation);
      return ({ name }) => colorFn(name);
    },

    labelPosition (d) {
      const {
        paddingForLabels,
        labelMargin,
        nodePadding,
      } = this.$options.viewOptions;

      const firstCol = d.x0 <= paddingForLabels;
      const lastCol = d.x1 >= this.width - paddingForLabels;

      if (firstCol) {
        return {
          x: 0 + labelMargin,
          y: d.y0,
          height: `${d.y1 - d.y0}px`,
          width: paddingForLabels - (2 * labelMargin),
          textAlign: 'right',
        }
      }

      if (lastCol) {
        return {
          x: (this.width - paddingForLabels) + labelMargin,
          y: d.y0,
          height: `${d.y1 - d.y0}px`,
          width: paddingForLabels - (2 * labelMargin),
          textAlign: 'left',
        }
      }

      return {
        x: (d.x1 + d.x0) / 2,
        y: d.y0 - nodePadding,
        height: `${nodePadding}px`,
        width: 'max-content',
        wrapperWidth: paddingForLabels - (2 * labelMargin),
        textAlign: d.x0 < this.width / 2 ? 'left' : 'right',
      }
    },

    transformData (parsed) {
      const { nodeWidth, nodePadding } = this.$options.viewOptions;
      const baseLayout = createSankey({ height: 10, width: 10, nodeWidth, nodePadding })(parsed);
      const cleanedNodes = removeOrphanNodes(baseLayout.nodes);
      const maxNodesPerLayer = getMaxNodes(cleanedNodes);

      return {
        maxNodesPerLayer,
        linksAndNodes: {
          links: parsed.links,
          nodes: cleanedNodes
        }
      }
    },
  },
}


</script>
<template>
  <div
    :class="$options.viewOptions.containerClasses"
    data-testid="dag-graph-container">
    <!-- graph goes here -->
  </div>
</template>
