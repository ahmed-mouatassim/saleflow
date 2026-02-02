-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Feb 01, 2026 at 10:04 AM
-- Server version: 10.11.14-MariaDB-cll-lve
-- PHP Version: 8.4.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `alidorma_saleflow`
--

-- --------------------------------------------------------

--
-- Table structure for table `prices`
--

CREATE TABLE `prices` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` varchar(100) NOT NULL,
  `price` decimal(10,3) NOT NULL,
  `date` date NOT NULL,
  `edite_by` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `prices`
--

INSERT INTO `prices` (`id`, `name`, `type`, `price`, `date`, `edite_by`) VALUES
(1, 'D22', 'spongeTypes', 2184.000, '2026-01-26', 'anass'),
(2, 'D20', 'spongeTypes', 1821.000, '2026-02-01', 'app'),
(3, 'ABS', 'spongeTypes', 2636.000, '2026-02-01', 'app'),
(4, 'D33', 'spongeTypes', 1490.000, '2026-01-26', 'anass'),
(5, 'HR D35', 'spongeTypes', 4001.000, '2026-02-01', 'app'),
(6, 'D33+ABS', 'spongeTypes', 1451.000, '2026-02-01', 'app'),
(7, 'D18', 'spongeTypes', 926.000, '2026-02-01', 'app'),
(8, 'footer_1m*2', 'footerTypes', 11.880, '2026-02-01', 'app'),
(20, 'defaultSpringValue', 'spring', 0.919, '2026-01-30', 'app'),
(21, 'defaultRibbon36mm', 'sfifa', 0.550, '2026-01-26', 'anass'),
(22, 'defaultRibbon18mm', 'sfifa', 0.350, '2026-01-26', 'anass'),
(23, 'defaultRibbon3D', 'sfifa', 2.500, '2026-01-26', 'anass'),
(24, 'defaultChainPrice', 'sfifa', 8.000, '2026-01-26', 'anass'),
(25, 'defaultElasticPrice', 'sfifa', 1.500, '2026-01-26', 'anass'),
(26, 'defaultCorners', 'Packaging Defaults', 6.500, '2026-01-26', 'anass'),
(27, 'defaultTickets', 'Packaging Defaults', 3.200, '2026-01-26', 'anass'),
(28, 'defaultPlastic', 'Packaging Defaults', 20.000, '2026-01-26', 'anass'),
(29, 'defaultRent', 'Cost Defaults', 1400.000, '2026-01-31', 'test'),
(30, 'defaultEmployees', 'Cost Defaults', 28576.000, '2026-01-26', 'anass'),
(31, 'defaultDiesel', 'Cost Defaults', 8402.000, '2026-01-31', 'app'),
(32, 'defaultElectricity', 'Cost Defaults', 1000.000, '2026-01-26', 'anass'),
(33, 'defaultProduction', 'Cost Defaults', 20.000, '2026-02-01', 'app'),
(73, 'ST2CMABS180G', 'dressTypes', 105.000, '2026-01-28', 'Ahmed'),
(74, 'a300G', 'dressTypes', 67.000, '2026-01-28', 'Ahmed'),
(75, 'ST300G', 'dressTypes', 52.000, '2026-01-28', 'Ahmed'),
(76, 'TP300G', 'dressTypes', 46.000, '2026-01-28', 'Ahmed'),
(77, 'TP180G', 'dressTypes', 45.000, '2026-01-28', 'Ahmed'),
(90, 'defaultWater', 'Cost Defaults', 23.000, '2026-01-30', 'system'),
(91, 'defaultInternet', 'Cost Defaults', 11.000, '2026-02-01', 'app'),
(92, 'defaultMaintenance', 'Cost Defaults', 44.000, '2026-02-01', 'app'),
(93, 'defaultTransport', 'Cost Defaults', 22.000, '2026-02-01', 'app'),
(94, 'defaultMarketing', 'Cost Defaults', 33.000, '2026-02-01', 'app'),
(95, 'defaultOtherMonthly', 'Cost Defaults', 55.000, '2026-02-01', 'app'),
(100, 'defaultScotch', 'Packaging Defaults', 0.000, '2026-01-30', 'system'),
(101, 'defaultOtherPackaging', 'Packaging Defaults', 0.000, '2026-01-30', 'system'),
(107, 'defaultThread', 'sfifa', 0.000, '2026-01-30', 'system'),
(111, 'defaultSpringSachet', 'spring', 402.000, '2026-02-01', 'app');

-- --------------------------------------------------------

--
-- Table structure for table `tarif`
--

CREATE TABLE `tarif` (
  `id` int(11) NOT NULL,
  `ref_mattress` varchar(50) DEFAULT NULL,
  `name` varchar(50) NOT NULL,
  `size` varchar(20) NOT NULL,
  `id_price` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `tarif`
--

INSERT INTO `tarif` (`id`, `ref_mattress`, `name`, `size`, `id_price`) VALUES
(25, 'REF-1769902126845', 'ST2CMABS180G', '190/140', 23);

-- --------------------------------------------------------

--
-- Table structure for table `tarif_details`
--

CREATE TABLE `tarif_details` (
  `id` int(11) NOT NULL,
  `sponge_price` decimal(10,2) DEFAULT 0.00,
  `springs_price` decimal(10,2) DEFAULT 0.00,
  `dress_price` decimal(10,2) DEFAULT 0.00,
  `sfifa_price` decimal(10,2) DEFAULT 0.00,
  `footer_price` decimal(10,2) DEFAULT 0.00,
  `packaging_price` decimal(10,2) DEFAULT 0.00,
  `cost_price` decimal(10,2) DEFAULT 0.00,
  `profit_price` decimal(10,3) DEFAULT 0.000,
  `la_marge` int(3) NOT NULL DEFAULT 0,
  `final_price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `tarif_details`
--

INSERT INTO `tarif_details` (`id`, `sponge_price`, `springs_price`, `dress_price`, `sfifa_price`, `footer_price`, `packaging_price`, `cost_price`, `profit_price`, `la_marge`, `final_price`) VALUES
(23, 0.00, 232.25, 592.55, 3.63, 63.20, 49.20, 75.77, 254.150, 0, 1270.75);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tarif`
--
ALTER TABLE `tarif`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ref_mattress` (`ref_mattress`),
  ADD KEY `fk_price` (`id_price`);

--
-- Indexes for table `tarif_details`
--
ALTER TABLE `tarif_details`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `prices`
--
ALTER TABLE `prices`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tarif`
--
ALTER TABLE `tarif`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `tarif_details`
--
ALTER TABLE `tarif_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `prices`
--
ALTER TABLE `prices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=112;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tarif`
--
ALTER TABLE `tarif`
  ADD CONSTRAINT `fk_price` FOREIGN KEY (`id_price`) REFERENCES `tarif_details` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
