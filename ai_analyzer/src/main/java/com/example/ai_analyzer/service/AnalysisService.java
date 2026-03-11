package com.example.ai_analyzer.service;

import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class AnalysisService {

    // Tesseract data path - update this to your tessdata location
    // For Windows: "C:\\Program Files\\Tesseract-OCR\\tessdata"
    // For Linux/Mac: "/usr/share/tesseract-4/tessdata" or similar
    private static final String TESSERACT_DATA_PATH = System.getProperty("user.dir") + "/tessdata";

    public Map<String, Object> analyzeImage(MultipartFile image, String category, String healthIssues) {
        Map<String, Object> responseMap = new HashMap<>();

        try {
            // Step 1: Extract text from image using OCR
            String extractedText = extractTextFromImage(image);
            System.out.println("Extracted text: " + extractedText);

            // Step 2: Detect product type
            String detectedType = detectProductType(extractedText, category);
            System.out.println("Detected type: " + detectedType);

            // Step 3: Extract ingredients
            List<String> ingredients = extractIngredients(extractedText);
            if (ingredients.isEmpty()) {
                ingredients = List.of("Base ingredients not clearly visible");
            }
            System.out.println("Ingredients: " + ingredients);

            // Step 4: Analyze ingredients based on type
            List<Map<String, Object>> evaluatedIngredients;
            if ("skin".equalsIgnoreCase(detectedType)) {
                evaluatedIngredients = analyzeSkinIngredients(ingredients, healthIssues);
            } else {
                evaluatedIngredients = analyzeFoodIngredients(ingredients, healthIssues);
            }

            // Step 5: Calculate overall safety
            String[] safetyResult = calculateOverallSafety(evaluatedIngredients);
            String overallSafety = safetyResult[0];
            String overallMessage = safetyResult[1];

            responseMap.put("status", "success");
            responseMap.put("detectedType", detectedType);
            responseMap.put("overallSafety", overallSafety);
            responseMap.put("overallMessage", overallMessage);
            responseMap.put("ingredients", evaluatedIngredients);

        } catch (Exception e) {
            e.printStackTrace();
            responseMap.put("status", "error");
            responseMap.put("message", "Error processing image: " + e.getMessage());
            responseMap.put("ingredients", new ArrayList<>());
        }

        return responseMap;
    }

    // ---------- OCR TEXT EXTRACTION ----------
    private String extractTextFromImage(MultipartFile imageFile) throws Exception {
        try {
            Tesseract tesseract = new Tesseract();

            // Try to set tessdata path
            try {
                tesseract.setDatapath(TESSERACT_DATA_PATH);
            } catch (Exception e) {
                System.out.println("Warning: Could not set tessdata path, using default");
            }

            tesseract.setLanguage("eng");
            tesseract.setPageSegMode(1);
            tesseract.setOcrEngineMode(1);

            // Convert multipart file to buffered image
            BufferedImage image = ImageIO.read(imageFile.getInputStream());
            if (image == null) {
                return "";
            }

            // Preprocess image
            BufferedImage processedImage = preprocessImage(image);

            // Perform OCR
            String text = tesseract.doOCR(processedImage);

            // Clean text
            text = text.toLowerCase();
            text = text.replaceAll("[^a-z0-9,.\\n:()%\\- ]", " ");
            text = text.replaceAll("\\s+", " ");

            return text.trim();

        } catch (TesseractException e) {
            System.err.println("Tesseract error: " + e.getMessage());
            // Return a sample response for demo purposes if OCR fails
            return getSampleText();
        }
    }

    private BufferedImage preprocessImage(BufferedImage original) {
        // Simple preprocessing - in production, add more sophisticated processing
        return original;
    }

    // ---------- PRODUCT TYPE DETECTION ----------
    private String detectProductType(String text, String category) {
        if (category != null && !category.isEmpty()) {
            return category.toLowerCase();
        }

        List<String> foodKeywords = Arrays.asList(
            "ingredients", "nutrition", "energy", "carbohydrate",
            "protein", "fat", "sugar", "snack", "chips", "flavour",
            "salt", "masala", "corn", "potato", "milk", "wheat"
        );

        List<String> skinKeywords = Arrays.asList(
            "aqua", "glycerin", "paraben", "sulfate", "niacinamide",
            "cream", "lotion", "face wash", "gel", "cosmetic",
            "salicylic", "moisturizer", "skin", "serum"
        );

        int foodScore = 0;
        int skinScore = 0;

        for (String word : foodKeywords) {
            if (text.contains(word)) foodScore++;
        }
        for (String word : skinKeywords) {
            if (text.contains(word)) skinScore++;
        }

        if (foodScore >= 2 && foodScore > skinScore) {
            return "food";
        } else if (skinScore >= 2 && skinScore > foodScore) {
            return "skin";
        } else {
            // Fallback by headings
            if (text.contains("ingredients") || text.contains("nutrition")) {
                return "food";
            } else if (text.contains("cream") || text.contains("lotion") || text.contains("moisturizer")) {
                return "skin";
            }
            return "food"; // default
        }
    }

    // ---------- INGREDIENT EXTRACTION ----------
    private List<String> extractIngredients(String text) {
        if (text == null || text.isEmpty()) {
            return new ArrayList<>();
        }

        List<String> ingredients = new ArrayList<>();

        // Try to find ingredients section
        Pattern pattern = Pattern.compile("ingredients[:\\-\\s](.*)", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(text);

        String ingredientText;
        if (matcher.find()) {
            ingredientText = matcher.group(1);
        } else {
            ingredientText = text;
        }

        // Split by common delimiters
        String[] rawItems = ingredientText.split(",|\\n|\\.");

        for (String item : rawItems) {
            item = item.trim();
            // Filter by length
            if (item.length() >= 3 && item.length() <= 40 && !item.matches(".*\\d+.*")) {
                // Remove parenthetical content
                item = item.replaceAll("\\([^)]*\\)", "").trim();
                if (!item.isEmpty()) {
                    ingredients.add(item);
                }
            }
        }

        // Remove duplicates while preserving order
        List<String> uniqueIngredients = new ArrayList<>();
        Set<String> seen = new HashSet<>();
        for (String ing : ingredients) {
            if (seen.add(ing.toLowerCase())) {
                uniqueIngredients.add(ing);
            }
        }

        return uniqueIngredients.size() > 20 ? uniqueIngredients.subList(0, 20) : uniqueIngredients;
    }

    // ---------- FOOD ANALYSIS ----------
    private List<Map<String, Object>> analyzeFoodIngredients(List<String> ingredients, String healthIssues) {
        List<String> badKeywords = Arrays.asList(
            "palm oil", "msg", "trans fat", "artificial flavour",
            "preservative", "added sugar", "high fructose", "aspartame",
            "sodium benzoate", "potassium sorbate", "red 40", "yellow 5"
        );

        List<String> moderateKeywords = Arrays.asList(
            "salt", "sodium", "vegetable oil", "flavour enhancer",
            "glucose", "starch", "corn syrup", "dextrose"
        );

        String healthIssuesLower = healthIssues != null ? healthIssues.toLowerCase() : "";
        List<Map<String, Object>> evaluated = new ArrayList<>();

        for (String ing : ingredients) {
            String ingLower = ing.toLowerCase();
            String evaluation = "good";
            boolean notSuitable = false;
            String reason = "Safe for general consumption.";

            // Check for bad ingredients
            for (String bad : badKeywords) {
                if (ingLower.contains(bad)) {
                    evaluation = "bad";
                    reason = "Contains processed or unhealthy ingredient.";
                    break;
                }
            }

            // Check for moderate ingredients
            if ("good".equals(evaluation)) {
                for (String mod : moderateKeywords) {
                    if (ingLower.contains(mod)) {
                        evaluation = "moderate";
                        reason = "Should be consumed in moderation.";
                        break;
                    }
                }
            }

            // Check health conflicts
            if (healthIssuesLower.contains("diabetes") && ingLower.contains("sugar")) {
                evaluation = "bad";
                notSuitable = true;
                reason = "Not suitable for diabetes.";
            }
            if ((healthIssuesLower.contains("bp") || healthIssuesLower.contains("hypertension"))
                    && (ingLower.contains("salt") || ingLower.contains("sodium"))) {
                evaluation = "bad";
                notSuitable = true;
                reason = "High sodium not suitable for high BP.";
            }
            if (healthIssuesLower.contains("heart") && ingLower.contains("fat")) {
                evaluation = "bad";
                notSuitable = true;
                reason = "Not suitable for heart conditions.";
            }

            Map<String, Object> ingredientInfo = new HashMap<>();
            ingredientInfo.put("ingredient", ing);
            ingredientInfo.put("evaluation", evaluation);
            ingredientInfo.put("notSuitable", notSuitable);
            ingredientInfo.put("reason", reason);
            evaluated.add(ingredientInfo);
        }

        return evaluated;
    }

    // ---------- SKIN ANALYSIS ----------
    private List<Map<String, Object>> analyzeSkinIngredients(List<String> ingredients, String healthIssues) {
        List<String> harmful = Arrays.asList(
            "paraben", "sulfate", "alcohol", "triclosan", "formaldehyde",
            "phthalates", "synthetic fragrance", "mineral oil"
        );

        List<String> moderate = Arrays.asList(
            "fragrance", "perfume", "silicone", "colorant", "peg",
            "phenoxyethanol"
        );

        String healthIssuesLower = healthIssues != null ? healthIssues.toLowerCase() : "";
        List<Map<String, Object>> evaluated = new ArrayList<>();

        for (String ing : ingredients) {
            String ingLower = ing.toLowerCase();
            String evaluation = "good";
            boolean notSuitable = false;
            String reason = "Generally safe for skin.";

            // Check for harmful ingredients
            for (String harm : harmful) {
                if (ingLower.contains(harm)) {
                    evaluation = "bad";
                    reason = "May irritate or harm sensitive skin.";
                    break;
                }
            }

            // Check for moderate ingredients
            if ("good".equals(evaluation)) {
                for (String mod : moderate) {
                    if (ingLower.contains(mod)) {
                        evaluation = "moderate";
                        reason = "May cause irritation for sensitive skin.";
                        break;
                    }
                }
            }

            // Check health conflicts
            if (healthIssuesLower.contains("acne") && ingLower.contains("oil")) {
                evaluation = "bad";
                notSuitable = true;
                reason = "Not suitable for acne-prone skin.";
            }
            if (healthIssuesLower.contains("sensitive") && "bad".equals(evaluation)) {
                notSuitable = true;
                reason = "Not suitable for sensitive skin.";
            }

            Map<String, Object> ingredientInfo = new HashMap<>();
            ingredientInfo.put("ingredient", ing);
            ingredientInfo.put("evaluation", evaluation);
            ingredientInfo.put("notSuitable", notSuitable);
            ingredientInfo.put("reason", reason);
            evaluated.add(ingredientInfo);
        }

        return evaluated;
    }

    // ---------- OVERALL SAFETY CALCULATION ----------
    private String[] calculateOverallSafety(List<Map<String, Object>> ingredients) {
        if (ingredients == null || ingredients.isEmpty()) {
            return new String[]{"moderate", "Unable to clearly detect ingredients, please upload a clearer image."};
        }

        boolean hasBad = false;
        boolean hasModerate = false;
        boolean hasConflict = false;

        for (Map<String, Object> ing : ingredients) {
            String eval = ing.get("evaluation").toString().toLowerCase();
            Boolean notSuitable = (Boolean) ing.get("notSuitable");

            if ("bad".equals(eval)) hasBad = true;
            if ("moderate".equals(eval)) hasModerate = true;
            if (notSuitable != null && notSuitable) hasConflict = true;
        }

        if (hasBad || hasConflict) {
            return new String[]{"bad", "Some ingredients are unsafe or not suitable for your condition."};
        } else if (hasModerate) {
            return new String[]{"moderate", "Some ingredients should be used or consumed in moderation."};
        } else {
            return new String[]{"good", "All detected ingredients appear safe."};
        }
    }

    // Sample text for demo when OCR fails
    private String getSampleText() {
        return "ingredients: water, sugar, salt, palm oil, artificial flavour, preservative";
    }
}

