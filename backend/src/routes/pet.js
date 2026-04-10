// src/routes/pet.js
const express = require('express');
const router = express.Router();
const { mockAuth, authMiddleware } = require('../middleware/auth');
const petController = require('../controllers/petController');

// router.use(mockAuth);
router.use(authMiddleware);

// POST /api/pet — создать питомца
/**
 * @swagger
 * /pet:
 *   post:
 *     summary: Create a pet for user
 *     tags: [Pet]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - petId
 *               - name
 *             properties:
 *               petId:
 *                 type: integer
 *                 example: 1
 *               name:
 *                 type: string
 *                 example: "Buddy"
 *                 maxLength: 50
 *     responses:
 *       201:
 *         description: Pet created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 pet:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                     user_id:
 *                       type: integer
 *                     pet_id:
 *                       type: integer
 *                     name:
 *                       type: string
 *                     level:
 *                       type: integer
 *                     exp:
 *                       type: integer
 *       400:
 *         description: Invalid input (missing petId or name)
 *       500:
 *         description: Server error
 */
router.post('/', petController.createPet);

// GET /api/pet — информация о питомце
/**
 * @swagger
 * /pet:
 *   get:
 *     summary: Get user pet information
 *     tags: [Pet]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Pet information
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: integer
 *                 name:
 *                   type: string
 *                 type:
 *                   type: string
 *                 avatar:
 *                   type: string
 *                 level:
 *                   type: integer
 *                 exp:
 *                   type: integer
 *                 exp_to_next_level:
 *                   type: integer
 *       404:
 *         description: Pet not found for this user
 *       500:
 *         description: Server error
 */
router.get('/', petController.getPet);

// PUT /api/pet/name — изменить имя питомца
/**
 * @swagger
 * /pet/name:
 *   put:
 *     summary: Update pet name
 *     tags: [Pet]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 example: "Charlie"
 *                 maxLength: 50
 *     responses:
 *       200:
 *         description: Pet name updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 new_name:
 *                   type: string
 *                   example: "Charlie"
 *       400:
 *         description: Invalid name
 *       404:
 *         description: Pet not found
 *       500:
 *         description: Server error
 */
router.put('/name', petController.updatePetName);

// GET /api/pet/types — список типов питомцев
/**
 * @swagger
 * /pet/types:
 *   get:
 *     summary: Get available pet types
 *     tags: [Pet]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of pet types
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 pets:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       type:
 *                         type: string
 *                       avatar:
 *                         type: string
 *       500:
 *         description: Server error
 */
router.get('/types', petController.getPetTypes);

module.exports = router;