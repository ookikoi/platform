import React from "react";
import { Box, Text } from "@chakra-ui/react";
import tokens from "../tokens";

interface RatingBadgeProps {
  rating: number;
  count?: number;
  size?: "sm" | "md" | "lg";
}

/**
 * RatingBadge — Display product rating with visual indicator
 *
 * Used on product cards, search results, review pages
 * Always shows rating out of 5, optionally shows review count
 *
 * Rule: design-system.md — uses tokens for color, spacing
 */
export const RatingBadge: React.FC<RatingBadgeProps> = ({
  rating,
  count,
  size = "md",
}) => {
  const sizeMap = {
    sm: { fontSize: tokens.text.sm, padding: tokens.space[2] },
    md: { fontSize: tokens.text.base, padding: tokens.space[3] },
    lg: { fontSize: tokens.text.base, padding: tokens.space[4] },
  };

  const colorMap = {
    excellent: tokens.color.success,
    good: tokens.color.primary,
    average: tokens.color.warning,
    poor: tokens.color.error,
  };

  let sentiment: keyof typeof colorMap;
  if (rating >= 4.5) sentiment = "excellent";
  else if (rating >= 3.5) sentiment = "good";
  else if (rating >= 2.5) sentiment = "average";
  else sentiment = "poor";

  return (
    <Box
      display="flex"
      alignItems="center"
      gap={tokens.space[2]}
      padding={sizeMap[size].padding}
      backgroundColor={`${colorMap[sentiment]}10`}
      borderRadius="md"
    >
      <Text
        fontSize={sizeMap[size].fontSize}
        fontWeight="bold"
        color={colorMap[sentiment]}
      >
        {rating.toFixed(1)}
      </Text>
      <Text fontSize="sm" color={tokens.color.text}>
        ★
      </Text>
      {count && (
        <Text fontSize="xs" color={tokens.color.text}>
          ({count.toLocaleString()} reviews)
        </Text>
      )}
    </Box>
  );
};

export default RatingBadge;
