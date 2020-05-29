import { sankey, sankeyLeft } from 'd3-sankey';

export const calculateClip = ({ y0, y1, source, target, width }) => {
  /*
    Because large link values can overrun their box, we create a clip path
    to trim off the excess in charts that have few nodes per column and are
    therefore tall.

    The box is created by
      M: moving to outside midpoint of the source node
      V: drawing a vertical line to maximum of the bottom link edge or
        the lowest edge of the node (can be d.y0 or d.y1 depending on the link's path)
      H: drawing a horizontal line to the outside edge of the destination node
      V: drawing a vertical line back up to the minimum of the top link edge or
        the highest edge of the node (can be d.y0 or d.y1 depending on the link's path)
      H: drawing a horizontal line back to the outside edge of the source node
      Z: closing the path, back to the start point
  */

  const bottomLinkEdge = Math.max(y1, y0) + width / 2;
  const topLinkEdge = Math.min(y0, y1) - width / 2;

  /* eslint-disable @gitlab/require-i18n-strings */
  return `
    M${source.x0}, ${y1}
    V${Math.max(bottomLinkEdge, y0, y1)}
    H${target.x1}
    V${Math.min(topLinkEdge, y0, y1)}
    H${source.x0}
    Z`;
  /* eslint-enable @gitlab/require-i18n-strings */
}

/*
    createSankey calls the d3 layout to generate the relationships and positioning
    values for the nodes and links in the graph.
  */

export const createSankey = ({
  width = 10,
  height = 10,
  nodeWidth = 10,
  nodePadding = 10,
  paddingForLabels = 1,
} = {}) => {
  const sankeyGenerator = sankey()
    .nodeId(({ name }) => name)
    .nodeAlign(sankeyLeft)
    .nodeWidth(nodeWidth)
    .nodePadding(nodePadding)
    .extent([
      [paddingForLabels, paddingForLabels],
      [width - paddingForLabels, height - paddingForLabels],
    ]);
  return ({ nodes, links }) =>
    sankeyGenerator({
      nodes: nodes.map(d => ({ ...d })),
      links: links.map(d => ({ ...d })),
    });
};

export const labelPosition = ({ x0, x1, y0, y1 }, viewOptions) => {
  const { paddingForLabels, labelMargin, nodePadding, width } = viewOptions;

  const firstCol = x0 <= paddingForLabels;
  const lastCol = x1 >= width - paddingForLabels;

  if (firstCol) {
    return {
      x: 0 + labelMargin,
      y: y0,
      height: `${y1 - y0}px`,
      width: paddingForLabels - 2 * labelMargin,
      textAlign: 'right',
    };
  }

  if (lastCol) {
    return {
      x: this.width - paddingForLabels + labelMargin,
      y: y0,
      height: `${y1 - y0}px`,
      width: paddingForLabels - 2 * labelMargin,
      textAlign: 'left',
    };
  }

  return {
    x: (x1 + x0) / 2,
    y: y0 - nodePadding,
    height: `${nodePadding}px`,
    width: 'max-content',
    wrapperWidth: paddingForLabels - 2 * labelMargin,
    textAlign: x0 < this.width / 2 ? 'left' : 'right',
  };
};
