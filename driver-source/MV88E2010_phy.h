/* Dummy MV88E2010 PHY header - firmware data not available */
#ifndef MV88E2010_PHY_H
#define MV88E2010_PHY_H

/* Empty firmware data array - driver will work without firmware for basic functionality */
static u16 MV88E2010_phy_initdata[] = {
	/* No firmware data - will skip firmware loading */
};

#endif /* MV88E2010_PHY_H */